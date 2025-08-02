
import {Timestamp} from "firebase-admin/firestore";

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
