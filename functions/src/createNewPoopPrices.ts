/* eslint-disable require-jsdoc */
import {admin} from "./admin";

export async function createNewPoopPricesFromLatest(prefix: string) {
  const db = admin.firestore();

  // 取得最新一筆價格資料
  const latestPriceSnap = await db.collection(`${prefix}prices`)
    .orderBy("createAt", "desc")
    .limit(1)
    .get();

  if (latestPriceSnap.empty) {
    console.log("No previous price found. Abort.");
    return null;
  }

  const lastDoc = latestPriceSnap.docs[0];
  const lastBuyPrice = lastDoc.data().buy;

  // TODO: 未來這裡應該計算從上一筆到現在的實際買賣成交量
  const buyVolume = 0;
  const sellVolume = 0;

  // 計算新價格（使用主人設計的 market formula）
  const baseVolatility = 0.03;
  const randomNoise = (Math.random() * 2 - 1) * baseVolatility;

  const netDemand = buyVolume - sellVolume;
  const demandFactor = netDemand / (buyVolume + sellVolume + 1e-6);
  const marketImpact = demandFactor * 0.02;

  const priceChangeRatio = randomNoise + marketImpact;
  const newBuyRaw = lastBuyPrice * (1 + priceChangeRatio);
  const newBuy = Math.round(newBuyRaw); // 四捨五入成整數
  const newSell = newBuy + 6; // 固定價差 +6，整數同樣成立

  const now = admin.firestore.Timestamp.now();

  // 建立新價格文件
  await db.collection(`${prefix}prices`).add({
    buy: newBuy,
    sell: newSell,
    createAt: now,
  });

  // eslint-disable-next-line max-len
  console.log(` New price added: lastBuy: ${lastBuyPrice}, buy = ${newBuy}, sell = ${newSell}`);
  return null;
}

export async function createNewPoopPricesFromAnnounce(
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  prefix: string, data: Record<string, any>
) {
  const mood = typeof data["mood"] === "number" ? data["mood"] : -1;
  if (mood == -1) return;
  if (mood < 0 || mood > 99) {
    console.warn("Invalid mood value:", mood);
    return null;
  }

  const db = admin.firestore();
  const latestPriceSnap = await db.collection(`${prefix}prices`)
    .orderBy("createAt", "desc")
    .limit(1)
    .get();

  if (latestPriceSnap.empty) {
    console.log("No previous price found. Abort.");
    return null;
  }

  const lastDoc = latestPriceSnap.docs[0];
  const lastBuyPrice = lastDoc.data().buy;

  const baseMood = 70;
  const deviation = (mood - baseMood) / 30; // 約 -2 ~ +1
  const maxImpact = 0.4;

  const logAdjusted =
    Math.sign(deviation) * Math.log1p(Math.abs(deviation * 0.8));
  const impact = Math.max(-1, Math.min(1, logAdjusted)) * maxImpact;

  const rawBuy = Math.round(lastBuyPrice * (1 + impact));
  const newBuy = Math.max(1, rawBuy);
  const newSell = newBuy + 6;

  const now = admin.firestore.Timestamp.now();

  // 建立新價格文件
  await db.collection(`${prefix}prices`).add({
    buy: newBuy,
    sell: newSell,
    createAt: now,
  });

  // eslint-disable-next-line max-len
  console.log(` New price added: mood=${mood}, buy = ${newBuy}, sell = ${newSell}`);
  return null;
}
