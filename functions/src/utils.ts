/* eslint-disable valid-jsdoc */
/* eslint-disable max-len */

import {Timestamp} from "firebase-admin/firestore";
import {PrayPoolEntry, PrayReward} from "./appConfig";

/* eslint-disable require-jsdoc */
export function limitConcurrency<T>(
  tasks: (() => Promise<T>)[],
  limit: number
): Promise<T[]> {
  const results: T[] = [];
  let index = 0;
  let active = 0;

  return new Promise((resolve, reject) => {
    function runNext() {
      if (index >= tasks.length && active === 0) return resolve(results);
      while (active < limit && index < tasks.length) {
        const current = index++;
        active++;
        tasks[current]()
          .then((result) => {
            results[current] = result;
            active--;
            runNext();
          })
          .catch(reject);
      }
    }
    runNext();
  });
}

// 工具函式：補零
function pad(num: number): string {
  return num.toString().padStart(2, "0");
}

// 傳回「目前時間」對應的月份 key（以台灣時間早上 8 點為分界）
export function getCurrentMonthKey(): string {
  const now = new Date(Date.now() + 8 * 60 * 60 * 1000); // UTC+8 調整成台灣時間

  const isBeforeCutoff = now.getUTCDate() === 1 && now.getUTCHours() < 8;

  const year = isBeforeCutoff ?
    now.getUTCMonth() === 0 ? now.getUTCFullYear() - 1 : now.getUTCFullYear() :
    now.getUTCFullYear();

  const month = isBeforeCutoff ?
    now.getUTCMonth() === 0 ? 12 : now.getUTCMonth() :
    now.getUTCMonth() + 1;

  return `${year}-${pad(month)}`;
}

// 傳回「上個月」的月份 key（同樣以台灣時間早上 8 點為分界）
export function getLastMonthKey(): string {
  const now = new Date(Date.now() + 8 * 60 * 60 * 1000); // UTC+8

  const isBeforeCutoff = now.getUTCDate() === 1 && now.getUTCHours() < 8;

  let year = now.getUTCFullYear();
  let month = now.getUTCMonth() + 1; // UTCMonth 是 0-based

  if (isBeforeCutoff) {
    month -= 1;
    if (month === 0) {
      month = 12;
      year -= 1;
    }
  } else {
    month -= 1;
    if (month === 0) {
      month = 12;
      year -= 1;
    }
  }

  return `${year}-${pad(month)}`;
}

export function getStartOfMonth8amInTaiwan(): Timestamp {
  const now = new Date();

  // 1. 建立一個表示「當月第一天，UTC 午夜 0 點」的 Date 物件
  const startOfMonth8amUTC = new Date(
    Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), 1, 0, 0)
  );

  // 2. 判斷當前時間（now）是否早於這個 UTC 午夜 0 點
  if (now.getTime() < startOfMonth8amUTC.getTime()) {
    // 3. 如果是，表示台灣時間還沒到當月 1 號的 8 點，所以回溯到上個月
    startOfMonth8amUTC.setUTCMonth(startOfMonth8amUTC.getUTCMonth() - 1);
  }

  return Timestamp.fromDate(startOfMonth8amUTC);
}

export function getDrinkFullyDecay(count: number): number {
  // 處理邊界情況
  if (count <= 0) {
    return 0;
  } else if (count > 8) {
    return getDrinkFullyDecay(8);
  }

  // 應用非線性方程式：f(x) = 10 * x^1.2
  const minutes = 10.0 * Math.pow(count, 1.2);

  // 將分鐘轉換為毫秒並四捨五入
  const milliseconds = Math.round(minutes * 60 * 1000);

  return milliseconds;
}

export function getTodayEffectiveStart(now: Date): Date {
  const TAIWAN_OFFSET_MS = 8 * 3600 * 1000;

  // 建立一個代表當前台灣時間的 Date 物件
  const nowInTaiwan = new Date(now.getTime() + TAIWAN_OFFSET_MS);

  // 使用 UTC 方法來取得台灣時間的年、月、日，避免本地時區干擾
  let year = nowInTaiwan.getUTCFullYear();
  let month = nowInTaiwan.getUTCMonth();
  let day = nowInTaiwan.getUTCDate();

  // 檢查台灣時間是否在早上 8 點之前
  if (nowInTaiwan.getUTCHours() < 8) {
    // 如果是，生效日就是「前一天」。
    // 我們從台灣當前時間減去 24 小時來安全地取得前一天的日期。
    const yesterdayInTaiwan = new Date(nowInTaiwan.getTime() - 24 * 3600 * 1000);
    year = yesterdayInTaiwan.getUTCFullYear();
    month = yesterdayInTaiwan.getUTCMonth();
    day = yesterdayInTaiwan.getUTCDate();
  }

  // 有效起始時間是該日期的台灣時間早上 8 點，
  // 這等同於 UTC 時間的凌晨 0 點。
  // 使用 Date.UTC() 來建立精確的 UTC 時間戳。
  return new Date(Date.UTC(year, month, day, 0, 0, 0));
}

interface UserTradingsNote {
  buyAmount: number;
  buyAverage: number;
  sellAmount: number;
  sellAverage: number;
}
export function applyTradingRecord(note: UserTradingsNote, userTradeType: "buy" | "sell", amount: number, price: number): UserTradingsNote {
  if (userTradeType === "buy") {
    const newBuyAmount = note.buyAmount + amount;
    const newBuyAverage = calcNewAverage(note.buyAmount, note.buyAverage, amount, price);
    return {
      ...note,
      buyAmount: newBuyAmount,
      buyAverage: newBuyAverage,
    };
  } else { // userTradeType === 'sell'
    const newSellAmount = note.sellAmount + amount;
    const newSellAverage = calcNewAverage(note.sellAmount, note.sellAverage, amount, price);
    return {
      ...note,
      sellAmount: newSellAmount,
      sellAverage: newSellAverage,
    };
  }
}

/**
 * 計算新的加權平均價格。
 */
export function calcNewAverage(currentAmount: number, currentAverage: number, newAmount: number, newPrice: number): number {
  if (currentAmount === 0) {
    return newPrice;
  }
  const totalAmount = currentAmount + newAmount;
  const totalValue = currentAmount * currentAverage + newAmount * newPrice;
  return totalValue / totalAmount;
}

/**
 * 從祈禱池中抽取一個獎勵
 * @param entries PrayPoolEntry 陣列
 * @returns PrayReward | null
 */
export function drawFromPrayPool(entries: PrayPoolEntry[]): PrayReward | null {
  if (!entries.length) return null;

  // 計算總機率
  const totalProbability = entries.reduce((sum, e) => sum + e.probability, 0);

  // 抽選 Entry
  let rand = Math.random() * totalProbability;
  let selectedEntry: PrayPoolEntry | null = null;

  for (const entry of entries) {
    if (rand < entry.probability) {
      selectedEntry = entry;
      break;
    }
    rand -= entry.probability;
  }

  if (!selectedEntry || !selectedEntry.rewards.length) return null;

  // 從該 Entry 的 rewards 中等機率選一個
  const rewardIndex = Math.floor(Math.random() * selectedEntry.rewards.length);
  return selectedEntry.rewards[rewardIndex];
}
