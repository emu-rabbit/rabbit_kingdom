/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable require-jsdoc */
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {logger} from "firebase-functions";
import {admin} from "./admin";
import GraphemeSplitter = require("grapheme-splitter");
import {AppConfig, fetchConfig} from "./appConfig";
import {getDrinkFullyDecay} from "./utils";

export async function processUserAction(request: CallableRequest<any>) {
  const uid = request.auth?.uid;

  if (!uid && typeof uid != "string") {
    throw new HttpsError("unauthenticated", "NOT-LOGIN");
  }

  const {env, action, payload} = request.data || {};
  if (!action) {
    throw new HttpsError("invalid-argument", "NO-ACTION");
  }
  if (!env || !["debug", "production"].includes(env)) {
    throw new HttpsError("invalid-argument", "BAD-ENV");
  }
  const prefix = env === "debug" ? "dev_": "";

  logger.info(`User: ${uid} with action ${action} in ${env}`, {payload});

  switch (action) {
  case "MODIFY_NAME":
    return await handleModifyName(prefix, uid, payload);
  case "DRINK":
    return await handleDrink(prefix, uid);
  default:
    throw new HttpsError("invalid-argument", "NO-ACTION");
  }
}

async function handleModifyName(prefix: string, uid: string, payload: any) {
  const {name: newName} = payload || {};
  let config: AppConfig;
  try {
    config = await fetchConfig(prefix);
  } catch (e) {
    throw new HttpsError("internal", "CONFIG_NOT_FOUND");
  }
  const cost = config.price_modify_name;
  const defaultName = config.default_name;
  const maxLength = config.name_max_length;

  // 1. 檢查新名稱是否有效
  if (!newName || typeof newName !== "string") {
    throw new HttpsError("invalid-argument", "INVALID-NAME");
  }

  // 2. 檢查名稱長度 (使用 grapheme-splitter)
  const splitter = new GraphemeSplitter();
  const graphemeCount = splitter.countGraphemes(newName);
  if (graphemeCount > maxLength) {
    throw new HttpsError("invalid-argument", "NAME-TOO-LONG");
  }

  // 3. 取得 Firestore 參考
  const userRef = admin.firestore().doc(`${prefix}user/${uid}`);

  // 4. 使用事務處理，以確保資料的一致性
  return admin.firestore().runTransaction(async (transaction) => {
    // 5. 讀取使用者資料
    const userDoc = await transaction.get(userRef);
    if (!userDoc.exists) {
      throw new HttpsError("not-found", "USER-NOT-FOUND");
    }
    const userData = userDoc.data();
    const currentName = userData?.name || defaultName;
    const currentCoins = userData?.budget?.coin || 0;

    // 6. 讀取 Firebase Auth 資料
    let authDisplayName = "";
    try {
      const userRecord = await admin.auth().getUser(uid);
      authDisplayName = userRecord.displayName || "";
    } catch (error) {
      // 捕獲 auth 錯誤，例如使用者不存在
      throw new HttpsError("internal", "USER-NOT-FOUND", error);
    }

    // 7. 判斷是否為免費改名
    const isFreeRename = (currentName === defaultName) ||
      (currentName === authDisplayName);
    let updateData: admin.firestore.UpdateData<any>;

    if (isFreeRename) {
      // 8. 免費改名，直接更新名稱
      updateData = {name: newName};
    } else {
      // 9. 付費改名，檢查遊戲幣餘額
      if (currentCoins < cost) {
        throw new HttpsError("failed-precondition", "COIN-NOT-ENOUGH");
      }
      // 10. 餘額足夠，更新名稱並扣除遊戲幣
      updateData = {
        "name": newName,
        "budget.coin": admin.firestore.FieldValue.increment(-cost),
      };
    }

    // 11. 執行更新
    transaction.update(userRef, updateData);

    return {success: true, message: "名稱更新成功！"};
  });
}

async function handleDrink(prefix: string, uid: string) {
  let config: AppConfig;
  try {
    config = await fetchConfig(prefix);
  } catch (e) {
    throw new HttpsError("internal", "CONFIG_NOT_FOUND");
  }
  const cost = config.price_drink;

  return admin.firestore().runTransaction(async (transaction) => {
    const userRef = admin.firestore().doc(`${prefix}user/${uid}`);
    const userDoc = await transaction.get(userRef);
    if (!userDoc.exists) {
      throw new HttpsError("not-found", "USER-NOT-FOUND");
    }

    const userData = userDoc.data();
    if (!userData) throw new HttpsError("not-found", "USER-NOT-FOUND");

    const currentCoins = userData.budget?.coin || 0;
    const currentDrinks = userData.drinks || {};

    if (currentCoins < cost) {
      throw new HttpsError("failed-precondition", "COIN-NOT-ENOUGH");
    }

    const now = new Date();

    // 🌟 修正點 1: 處理 Firestore Timestamp
    const lastDrinkTime = currentDrinks.lastAt?.toDate() ||
      new Date(0); // 如果沒有 lastAt，則使用一個很早的時間
    const timeDifference = now.getTime() - lastDrinkTime.getTime();
    const decayTime = getDrinkFullyDecay(currentDrinks.count || 0);

    // 檢查是否完全消散
    const fullyDecayed: boolean = timeDifference > decayTime;

    // 🌟 修正點 2: 正確呼叫 serverTimestamp 屬性
    transaction.update(userRef, {
      "budget.coin": admin.firestore.FieldValue.increment(-cost),
      "drinks.count": fullyDecayed ? 1 : (currentDrinks.count || 0) + 1,
      "drinks.total": admin.firestore.FieldValue.increment(1),
      "drinks.lastAt": admin.firestore.FieldValue.serverTimestamp(),
    });

    return {success: true, message: "喝酒成功！"};
  });
}
