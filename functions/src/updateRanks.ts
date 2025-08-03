/* eslint-disable max-len */

import {Timestamp} from "firebase-admin/firestore";
import {getCurrentMonthKey, getStartOfMonth8amInTaiwan, limitConcurrency} from "./utils";
import {admin} from "./admin";

/* eslint-disable require-jsdoc */
export async function updateRanks(prefix: string) {
  const env = prefix;
  const monthKey = getCurrentMonthKey();

  const db = admin.firestore();
  const userRef = db.collection(`${env}user`);
  const ranksRef = db.collection(`${env}ranks`);
  const tradingsRef = db.collection(`${env}tradings`);
  const price = await db.collection(`${env}prices`)
    .orderBy("createAt", "desc")
    .limit(1)
    .get();
  const buy = price.docs[0].data().buy ?? null;
  if (buy === null) throw Error("Cannot get buy price");

  const monthStart = getStartOfMonth8amInTaiwan();

  // 設定每頁處理的使用者數量
  const pageSize = 200;

  // 紀錄最後一個使用者文件，用於下一頁查詢
  let lastUserDoc = null;
  let lastTradingTime = null as Timestamp | null;

  // 進入迴圈，直到所有使用者文件都處理完畢
  // eslint-disable-next-line no-constant-condition
  while (true) {
    let userQuery = userRef
      .where("group", "!=", "unknown")
      .orderBy("group")
      .orderBy(admin.firestore.FieldPath.documentId())
      .limit(pageSize);

    // 如果不是第一頁，則從上次查詢的最後一個文件開始
    if (lastUserDoc) {
      userQuery = userQuery.startAfter(lastUserDoc);
    }

    // 取得一頁使用者文件
    const userSnapshot = await userQuery.get();

    // 如果沒有更多文件，則結束迴圈
    if (userSnapshot.empty) {
      break;
    }

    // 儲存最後一個文件，以便下一頁使用
    lastUserDoc = userSnapshot.docs[userSnapshot.docs.length - 1];

    // 從使用者文件中取得所有 id
    const userIds = userSnapshot.docs.map((doc) => doc.id);

    // 將 userIds 分割成每組 10 個 id，以符合 Firestore in 運算子的限制
    const chunks = [];
    for (let i = 0; i < userIds.length; i += 10) {
      chunks.push(userIds.slice(i, i + 10));
    }

    // 儲存這一頁所有的排行文件
    const ranksMap = new Map<string, admin.firestore.DocumentData>();

    // 透過迴圈，對每一組 id 進行查詢
    for (const chunk of chunks) {
      const ranksSnapshot = await ranksRef
        .where(admin.firestore.FieldPath.documentId(), "in", chunk).get();
      ranksSnapshot.forEach((doc) => {
        ranksMap.set(doc.id, doc.data());
      });
    }

    const tradingMap = new Map<string, admin.firestore.DocumentData[]>();
    for (const chunk of chunks) {
      const tradingSnaps = await tradingsRef
        .where("userID", "in", chunk)
        .where("createAt", ">=", monthStart)
        .get();

      tradingSnaps.forEach((doc) => {
        const data = doc.data();
        const uid = data["userID"];
        if (!tradingMap.has(uid)) {
          tradingMap.set(uid, []);
        }
        tradingMap.get(uid)?.push(data);
        if (data["createAt"] instanceof Timestamp) {
          if (
            lastTradingTime === null ||
                        data["createAt"].toMillis() > lastTradingTime.toMillis()
          ) {
            lastTradingTime = data["createAt"];
          }
        }
      });
    }

    // 這裡開始，您可以實作您自己的邏輯
    // 1. userSnapshot.docs: 包含了這 200 位使用者的文件
    // 2. ranksMap: 包含了這 200 位使用者的排行文件，鍵值為使用者 id
    //
    // 範例：將使用者資料與排行資料合併
    const tasks = userSnapshot.docs.map((userDoc) => (
      async () => {
        const userData = userDoc.data();
        const rankData = ranksMap.get(userDoc.id);
        const tradingData = tradingMap.get(userDoc.id) ?? [];

        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const newRankData = {} as any;

        newRankData.property = getPropertyField(buy, monthKey, userData, rankData);
        newRankData.coin = getCoinField(monthKey, userData, rankData);
        newRankData.poop = getPoopField(monthKey, userData, rankData);
        newRankData.exp = getExpField(monthKey, userData, rankData);
        newRankData.drink = getDrinkField(monthKey, userData, rankData);
        newRankData.tradingVolume = getTradingVolumeField(monthKey, userData, tradingData);
        newRankData.buyAvg = getBuyAvgField(monthKey, userData, tradingData);
        newRankData.sellAvg = getSellAvgField(monthKey, userData, tradingData);
        newRankData.tradingAvgDif = getTradingAvgDifField(monthKey, newRankData.buyAvg, newRankData.sellAvg);

        await ranksRef.doc(userDoc.id).set(newRankData);
      }
    ));

    await limitConcurrency(tasks, 5);

    console.log(`已處理 ${userSnapshot.docs.length} 個使用者與其排行文件，下一頁將繼續...`);
  }
  // TODO set meta
  console.log("所有使用者與排行文件都已處理完畢。");
}


function getPropertyField(
  buy: number,
  monthKey: string,
  userData: admin.firestore.DocumentData,
  rankData: admin.firestore.DocumentData | undefined,
) {
  const coin = userData.budget?.coin ?? 0;
  const poop = userData.budget?.poop ?? 0;
  const property = coin + poop * buy;
  const lastProperty = rankData?.["property"]?.all ?? 0;
  const currentMonthProperty = rankData?.["property"]?.[monthKey] ?? 0;
  const growth = property - lastProperty;
  return {
    all: property,
    [monthKey]: currentMonthProperty + growth,
    currentMonth: currentMonthProperty + growth,
  };
}

function getCoinField(
  monthKey: string,
  userData: admin.firestore.DocumentData,
  rankData: admin.firestore.DocumentData | undefined,
) {
  const coin = userData.budget?.coin ?? 0;
  const lastCoin = rankData?.["coin"]?.all ?? 0;
  const currentMonthCoin = rankData?.["coin"]?.[monthKey] ?? 0;
  const growth = coin - lastCoin;
  return {
    all: coin,
    [monthKey]: currentMonthCoin + growth,
    currentMonth: currentMonthCoin + growth,
  };
}


function getPoopField(
  monthKey: string,
  userData: admin.firestore.DocumentData,
  rankData: admin.firestore.DocumentData | undefined,
) {
  const poop = userData.budget?.poop ?? 0;
  const lastPoop = rankData?.["poop"]?.all ?? 0;
  const currentMonthPoop = rankData?.["poop"]?.[monthKey] ?? 0;
  const growth = poop - lastPoop;
  return {
    all: poop,
    [monthKey]: currentMonthPoop + growth,
    currentMonth: currentMonthPoop + growth,
  };
}

function getExpField(
  monthKey: string,
  userData: admin.firestore.DocumentData,
  rankData: admin.firestore.DocumentData | undefined,
) {
  const exp = userData.exp ?? 0;
  const lastExp = rankData?.["exp"]?.all ?? 0;
  const currentMonthExp = rankData?.["exp"]?.[monthKey] ?? 0;
  const growth = exp - lastExp;
  return {
    all: exp,
    [monthKey]: currentMonthExp + growth,
    currentMonth: currentMonthExp + growth,
  };
}


function getDrinkField(
  monthKey: string,
  userData: admin.firestore.DocumentData,
  rankData: admin.firestore.DocumentData | undefined,
) {
  const drink = userData.drinks?.total?? 0;
  const lastDrink = rankData?.["drink"]?.all ?? 0;
  const currentMonthDrink = rankData?.["drink"]?.[monthKey] ?? 0;
  const growth = drink - lastDrink;
  return {
    all: drink,
    [monthKey]: currentMonthDrink + growth,
    currentMonth: currentMonthDrink + growth,
  };
}

function getTradingVolumeField(
  monthKey: string,
  userData: admin.firestore.DocumentData,
  tradingData: admin.firestore.DocumentData[]
) {
  const volume = tradingData
    .map<number>((t) => t.amount ?? 0)
    .reduce((t, c) => c + (t ?? 0), 0);
  const buy = userData.note?.["buyAmount"] ?? 0;
  const sell = userData.note?.["sellAmount"] ?? 0;
  return {
    all: buy + sell,
    [monthKey]: volume,
    currentMonth: volume,
  };
}

function getBuyAvgField(
  monthKey: string,
  userData: admin.firestore.DocumentData,
  tradingData: admin.firestore.DocumentData[]
) {
  const summary = {
    buyVolume: 0,
    buyTotalPrice: 0,
  }; // 您的 summary 邏輯
  tradingData.forEach((data) => {
    // 執行計算
    const type = data["type"];
    const amount = data["amount"] ?? 0;
    const price = data["price"] ?? 0;
    if (type === "sell") {
      summary.buyVolume += amount;
      summary.buyTotalPrice += amount * price;
    }
  });
  const buyAvg = summary.buyVolume > 0 ?
    summary.buyTotalPrice / summary.buyVolume :
    null;

  return {
    all: userData.note?.["buyAverage"] ?? null,
    [monthKey]: buyAvg,
    currentMonth: buyAvg,
  };
}


function getSellAvgField(
  monthKey: string,
  userData: admin.firestore.DocumentData,
  tradingData: admin.firestore.DocumentData[]
) {
  const summary = {
    sellVolume: 0,
    sellTotalPrice: 0,
  }; // 您的 summary 邏輯
  tradingData.forEach((data) => {
    // 執行計算
    const type = data["type"];
    const amount = data["amount"] ?? 0;
    const price = data["price"] ?? 0;
    if (type === "buy") {
      summary.sellVolume += amount;
      summary.sellTotalPrice += amount * price;
    }
  });
  const sellAvg = summary.sellVolume > 0 ?
    summary.sellTotalPrice / summary.sellVolume :
    null;

  return {
    all: userData.note?.["sellAverage"] ?? null,
    [monthKey]: sellAvg,
    currentMonth: sellAvg,
  };
}

function getTradingAvgDifField(
  monthKey: string,
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  buy: any,
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  sell: any
) {
  const buyAll = buy["all"] ?? null;
  const sellAll = sell["all"] ?? null;
  const all = buyAll !== null && sellAll !== null ? sellAll - buyAll : null;
  const buyMonth = buy["currentMonth"] ?? null;
  const sellMonth = sell["currentMonth"] ?? null;
  const month = buyMonth !== null && sellMonth !== null ? sellMonth - buyMonth : null;
  return {
    all: all,
    [monthKey]: month,
    currentMonth: month,
  };
}
