/* eslint-disable max-len */
/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable require-jsdoc */
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {logger} from "firebase-functions";
import {admin} from "./admin";
import GraphemeSplitter = require("grapheme-splitter");
import {AppConfig, fetchConfig} from "./appConfig";
import {applyTradingRecord, drawFromPrayPool, getDrinkFullyDecay, getTodayEffectiveStart} from "./utils";

export async function processUserAction(request: CallableRequest<any>) {
  const uid = request.auth?.uid;

  if (!uid && typeof uid != "string") {
    throw new HttpsError("unauthenticated", "NOT_LOGIN");
  }

  const {env, action, payload} = request.data || {};
  if (!action) {
    throw new HttpsError("invalid-argument", "NO_ACTION");
  }
  if (!env || !["debug", "production"].includes(env)) {
    throw new HttpsError("invalid-argument", "BAD_ENV");
  }
  const prefix = env === "debug" ? "dev_": "";

  logger.info(`User: ${uid} with action ${action} in ${env}`, {payload});

  await admin
    .firestore()
    .collection(`${prefix}logs`)
    .doc(uid)
    .collection("actions")
    .add({
      action: action,
      time: admin.firestore.Timestamp.now(),
      payload: payload,
    });

  switch (action) {
  case "CREATE_USER":
    return await handleCreateUser(prefix, uid);
  case "MODIFY_NAME":
    return await handleModifyName(prefix, uid, payload);
  case "DRINK":
    return await handleDrink(prefix, uid);
  case "COMPLETE_TASK":
    return await handleTaskComplete(prefix, uid, payload);
  case "COMMENT_ANNOUNCE":
    return await handleCommentAnnounce(prefix, uid, payload);
  case "HEART_ANNOUNCE":
    return await handleHeartAnnounce(prefix, uid, payload);
  case "TRADE":
    return await handleTrade(prefix, uid, payload);
  case "AD_WATCHED":
    return await handleAdWatched(prefix, uid);
  case "REACT_NEWS":
    return await handleReactNews(prefix, uid, payload);
  case "MAKE_PRAY":
    return await handleMakePray(prefix, uid, payload);
  default:
    throw new HttpsError("invalid-argument", "NO_ACTION");
  }
}

async function handleCreateUser(prefix: string, uid: string) {
  let config: AppConfig;
  try {
    config = await fetchConfig(prefix);
  } catch (e) {
    throw new HttpsError("internal", "CONFIG_NOT_FOUND");
  }
  const userRef = admin.firestore().doc(`${prefix}user/${uid}`);

  return await admin.firestore().runTransaction(async (transaction) => {
    // 1. 在事務中讀取文件
    const userDoc = await transaction.get(userRef);

    // 2. 檢查文件是否存在
    if (!userDoc.exists) {
      let userRecord;
      try {
        // 3. 如果不存在，則在事務中創建它
        userRecord = await admin.auth().getUser(uid);
      } catch (error) {
        // 捕獲 auth 錯誤，例如使用者不存在
        throw new HttpsError("internal", "USER_NOT_FOUND", error);
      }
      const records: { [key in string]: admin.firestore.Timestamp[] } = {};
      Object.entries(config.kingdom_tasks).forEach(([key]) => {
        records[key] = [];
      });
      const newUser = {
        name: userRecord.displayName || config.default_name,
        email: userRecord.email || "unknown",
        createAt: admin.firestore.FieldValue.serverTimestamp(),
        group: "unknown",
        exp: 0,
        budget: {
          "coin": 0,
          "poop": 0,
        },
        records: records,
        drinks: {
          "count": 0,
          "total": 0,
          "lastAt": admin.firestore.Timestamp.now(),
        },
        note: {
          "buyAmount": 0,
          "buyAverage": null,
          "sellAmount": 0,
          "sellAverage": null,
        },
        ad: {
          "count": 0,
        },
      };
      transaction.set(userRef, newUser);
      return {success: true, message: "名稱更新成功！"};
    } else {
      throw new HttpsError("already-exists", "USER_EXIST");
    }
  });
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
    throw new HttpsError("invalid-argument", "INVALID_NAME");
  }

  // 2. 檢查名稱長度 (使用 grapheme_splitter)
  const splitter = new GraphemeSplitter();
  const graphemeCount = splitter.countGraphemes(newName);
  if (graphemeCount > maxLength) {
    throw new HttpsError("invalid-argument", "NAME_TOO_LONG");
  }

  // 3. 取得 Firestore 參考
  const userRef = admin.firestore().doc(`${prefix}user/${uid}`);

  // 4. 使用事務處理，以確保資料的一致性
  return admin.firestore().runTransaction(async (transaction) => {
    // 5. 讀取使用者資料
    const userDoc = await transaction.get(userRef);
    if (!userDoc.exists) {
      throw new HttpsError("not-found", "USER_NOT_FOUND");
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
      throw new HttpsError("internal", "USER_NOT_FOUND", error);
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
        throw new HttpsError("failed-precondition", "COIN_NOT_ENOUGH");
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
      throw new HttpsError("not-found", "USER_NOT_FOUND");
    }

    const userData = userDoc.data();
    if (!userData) throw new HttpsError("not-found", "USER_NOT_FOUND");

    const currentCoins = userData.budget?.coin || 0;
    const currentDrinks = userData.drinks || {};

    if (currentCoins < cost) {
      throw new HttpsError("failed-precondition", "COIN_NOT_ENOUGH");
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

async function handleTaskComplete(prefix: string, uid: string, payload: any) {
  const {taskName} = payload || {};
  if (!taskName) throw new HttpsError("invalid-argument", "BAD_TASK_NAME");

  let config: AppConfig;
  try {
    // 這裡需要一個更完整的配置，包含所有任務的資料
    config = await fetchConfig(prefix);
  } catch (e) {
    throw new HttpsError("internal", "CONFIG_NOT_FOUND");
  }

  // 檢查任務名稱是否有效
  const taskConfig = config.kingdom_tasks?.[taskName]; // 假設 AppConfig 有 tasks 欄位
  if (!taskConfig) {
    throw new HttpsError("invalid-argument", "TASK_NOT_FOUND");
  }

  // 使用 Firestore 事務確保原子性
  return admin.firestore().runTransaction(async (transaction) => {
    const userRef = admin.firestore().doc(`${prefix}user/${uid}`);
    const userDoc = await transaction.get(userRef);

    if (!userDoc.exists) {
      throw new HttpsError("not-found", "USER_NOT_FOUND");
    }

    const userData = userDoc.data();
    if (!userData) {
      throw new HttpsError("not-found", "USER_NOT_FOUND");
    }
    // 檢查使用者群組
    if (userData.group === "unknown") {
      throw new HttpsError("not-found", "USER_UNKNOWN");
    }

    // 1. 計算已完成次數
    const now = new Date();
    const todayEffectiveStart = getTodayEffectiveStart(now);

    // eslint_disable_next_line max_len
    const oldRecords = (userData.records?.[taskName] ?? []) as admin.firestore.Timestamp[];
    const recordsToday = oldRecords.filter((recordTimestamp) => {
      // 確保 Timestamp 物件存在，並與 todayEffectiveStart 比較
      const localTime = recordTimestamp.toDate();
      return localTime.getTime() >= todayEffectiveStart.getTime();
    });

    // 檢查是否已達上限
    if (recordsToday.length >= taskConfig.limit) {
      throw new HttpsError("failed-precondition", "TASK_OUT_OF_LIMIT");
    }

    // 2. 清理舊紀錄並新增新紀錄
    const newRecords = recordsToday;
    newRecords.push(admin.firestore.Timestamp.now());

    // 3. 執行更新
    const updateData: { [key: string]: any } = {
      [`records.${taskName}`]: newRecords,
      "exp": admin.firestore.FieldValue.increment(taskConfig.exp_reward),
      // eslint_disable_next_line max_len
      "budget.coin": admin.firestore.FieldValue.increment(taskConfig.coin_reward),
    };

    transaction.update(userRef, updateData);

    return {
      success: true,
      message: `任務 '${taskName}' 完成！`,
      rewards: {
        coin: taskConfig.coin_reward,
        exp: taskConfig.exp_reward,
      },
    };
  });
}

async function handleCommentAnnounce(prefix: string, uid: string, payload: any) {
  const {comment, id: announceID} = payload || {};// 1. 檢查新名稱是否有效
  if (!comment || typeof comment !== "string") {
    throw new HttpsError("invalid-argument", "INVALID_COMMENT");
  }

  // 2. 檢查名稱長度 (使用 grapheme_splitter)
  // const splitter = new GraphemeSplitter();
  // const graphemeCount = splitter.countGraphemes(newName);
  // if (graphemeCount > maxLength) {
  //   throw new HttpsError("invalid-argument", "NAME_TOO_LONG");
  // }

  const userRef = admin.firestore().doc(`${prefix}user/${uid}`);
  const announceRef = admin.firestore().doc(`${prefix}announce/${announceID}`);
  return admin.firestore().runTransaction(async (transaction) => {
    // 5. 讀取使用者資料
    const userDoc = await transaction.get(userRef);
    if (!userDoc.exists) {
      throw new HttpsError("not-found", "USER_NOT_FOUND");
    }
    const userData = userDoc.data();
    if (!userData) {
      throw new HttpsError("not-found", "USER_NOT_FOUND");
    }
    const announceDoc = await transaction.get(announceRef);
    if (!announceDoc.exists) {
      throw new HttpsError("not-found", "ANNOUNCE_NOT_FOUND");
    }
    transaction.update(announceRef, {
      "comments": admin.firestore.FieldValue.arrayUnion({
        "uid": uid,
        "name": userData.name,
        "group": userData.group,
        "message": comment,
        "createAt": admin.firestore.Timestamp.now(),
      }),
    });
    return {success: true, message: "成功回覆"};
  });
}

async function handleHeartAnnounce(prefix: string, uid: string, payload: any) {
  const {id: announceID} = payload || {};

  const userRef = admin.firestore().doc(`${prefix}user/${uid}`);
  const announceRef = admin.firestore().doc(`${prefix}announce/${announceID}`);
  return admin.firestore().runTransaction(async (transaction) => {
    // 5. 讀取使用者資料
    const userDoc = await transaction.get(userRef);
    if (!userDoc.exists) {
      throw new HttpsError("not-found", "USER_NOT_FOUND");
    }
    const userData = userDoc.data();
    if (!userData) {
      throw new HttpsError("not-found", "USER_NOT_FOUND");
    }
    const announceDoc = await transaction.get(announceRef);
    if (!announceDoc.exists) {
      throw new HttpsError("not-found", "ANNOUNCE_NOT_FOUND");
    }
    transaction.update(announceRef, {
      "hearts": admin.firestore.FieldValue.arrayUnion({
        "uid": uid,
        "name": userData.name,
      }),
    });
    return {success: true, message: "成功回覆"};
  });
}

async function handleTrade(prefix: string, uid: string, payload: any) {
  const {type, amount, price} = payload;

  if (!type || !amount || !price || !["buy", "sell"].includes(type) || amount <= 0 || price <= 0) {
    throw new HttpsError("invalid-argument", "INVALID_ARGUMENTS");
  }

  // 1. 取得價格，並驗證前端傳來的價格
  const pricesRef = admin.firestore().collection(`${prefix}prices`);
  const pricesSnapshot = await pricesRef.orderBy("createAt", "desc").limit(3).get();

  let isPriceValid = false;
  let serverPrice = 0;

  if (pricesSnapshot.empty) {
    throw new HttpsError("internal", "NO_PRICES");
  }

  // 比對前端價格與後端最新三筆價格
  pricesSnapshot.forEach((doc) => {
    const priceData = doc.data();
    if (type === "buy" && priceData.buy === price) {
      isPriceValid = true;
      serverPrice = priceData.buy;
    } else if (type === "sell" && priceData.sell === price) {
      isPriceValid = true;
      serverPrice = priceData.sell;
    }
  });

  if (!isPriceValid) {
    throw new HttpsError("failed-precondition", "INVALID_PRICE");
  }

  // 2. 進行交易，使用事務確保原子性
  return admin.firestore().runTransaction(async (transaction) => {
    const userRef = admin.firestore().doc(`${prefix}user/${uid}`);
    const tradingsRef = admin.firestore().collection(`${prefix}tradings`);
    const userDoc = await transaction.get(userRef);

    if (!userDoc.exists) {
      throw new HttpsError("not-found", "USER_NOT_FOUND");
    }

    const userData = userDoc.data();
    if (!userData || !userData.budget) {
      throw new HttpsError("not-found", "USER_NOT_FOUND");
    }

    const cost = amount * serverPrice;
    let newCoinAmount = userData.budget.coin;
    let newPoopAmount = userData.budget.poop;
    let newTradingsNote = userData.note || { // 確保有預設值
      buyAmount: 0,
      buyAverage: 0,
      sellAmount: 0,
      sellAverage: 0,
    };

    // 處理賣出（付出 poop，獲得 coin）
    if (type === "buy") {
      if (userData.budget.poop < amount) {
        throw new HttpsError("failed-precondition", "NO_POOP");
      }
      newPoopAmount -= amount;
      newCoinAmount += cost;

      newTradingsNote = applyTradingRecord(newTradingsNote, "sell", amount, serverPrice);
    // eslint-disable-next-line brace-style
    }
    // 處理買入（獲得 poop，付出 coin）
    else if (type === "sell") {
      if (userData.budget.coin < cost) {
        throw new HttpsError("failed-precondition", "NO_COIN");
      }
      newCoinAmount -= cost;
      newPoopAmount += amount;

      newTradingsNote = applyTradingRecord(newTradingsNote, "buy", amount, serverPrice);
    }

    // 3. 更新使用者資料
    transaction.update(userRef, {
      "budget.coin": newCoinAmount,
      "budget.poop": newPoopAmount,
      "note": newTradingsNote,
    });

    // 4. 新增交易記錄
    const tradingRecord = {
      userID: uid,
      type: type,
      amount: amount,
      price: serverPrice,
      createAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    transaction.set(tradingsRef.doc(), tradingRecord);

    return {success: true, message: "交易成功！"};
  });
}

async function handleAdWatched(prefix: string, uid: string) {
  const userRef = admin.firestore().doc(`${prefix}user/${uid}`);
  return userRef.update({
    "ad.count": admin.firestore.FieldValue.increment(1),
  });
}

async function handleReactNews(prefix: string, uid: string, payload: any) {
  const {id, good} = payload;

  // 1. 驗證傳入參數
  if (!id || typeof good !== "boolean") {
    throw new HttpsError("invalid-argument", "INVALID_ARGUMENTS");
  }

  const newsRef = admin.firestore().doc(`${prefix}news/${id}`);

  // 2. 使用事務確保操作的原子性
  return admin.firestore().runTransaction(async (transaction) => {
    const newsDoc = await transaction.get(newsRef);

    if (!newsDoc.exists) {
      throw new HttpsError("not-found", "NEWS_NOT_FOUND");
    }

    const newsData = newsDoc.data();
    if (!newsData) {
      throw new HttpsError("internal", "NEWS_NOT_FOUND");
    }

    // 3. 檢查使用者是否已回應過
    if (newsData.goods.includes(uid) || newsData.bads.includes(uid)) {
      throw new HttpsError("failed-precondition", "ALREADY_REACTED");
    }

    // 4. 根據 good 值更新對應的陣列
    if (good) {
      transaction.update(newsRef, {
        goods: admin.firestore.FieldValue.arrayUnion(uid),
      });
    } else {
      transaction.update(newsRef, {
        bads: admin.firestore.FieldValue.arrayUnion(uid),
      });
    }

    return {success: true, message: "回應成功！"};
  });
}

async function handleMakePray(prefix: string, uid: string, payload: any) {
  const {type} = payload;

  // 1. 驗證傳入參數
  if (!type || typeof type !== "string" || !["simple", "advance"].includes(type)) {
    throw new HttpsError("invalid-argument", "INVALID_ARGUMENTS");
  }

  let config: AppConfig;
  try {
    // 這裡需要一個更完整的配置，包含所有任務的資料
    config = await fetchConfig(prefix);
  } catch (e) {
    throw new HttpsError("internal", "CONFIG_NOT_FOUND");
  }

  const pool = type === "simple" ? config.pray_pool.simple : config.pray_pool.advance;

  return admin.firestore().runTransaction(async (transaction) => {
    const userRef = admin.firestore().collection(`${prefix}user`).doc(uid);
    const userDoc = await transaction.get(userRef);

    const userData = userDoc.data();
    if (!userData) {
      throw new HttpsError("not-found", "USER_NOT_FOUND");
    }

    if (userData.pray?.pending) {
      throw new HttpsError("already-exists", "Pending pray exist");
    }

    const rewardA = drawFromPrayPool(pool);
    const rewardB = drawFromPrayPool(pool);
    if (!rewardA || !rewardB) {
      throw new HttpsError("internal", "POOL_DRAW_ERROR");
    }

    transaction.update(userRef, {
      "pray.pending": {
        rewardA: rewardA,
        rewardB: rewardB,
      },
    });

    return {success: true, message: "成功抽選"};
  });
}
