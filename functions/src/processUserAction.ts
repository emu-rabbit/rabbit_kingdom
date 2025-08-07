/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable require-jsdoc */
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {logger} from "firebase-functions";
import {admin} from "./admin";
import GraphemeSplitter = require("grapheme-splitter");

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
  default:
    throw new HttpsError("invalid-argument", "NO-ACTION");
  }
}

async function handleModifyName(prefix: string, uid: string, payload: any) {
  const {name: newName} = payload || {};
  const cost = 100;
  const defaultName = "未命名";
  const maxLength = 10;

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
