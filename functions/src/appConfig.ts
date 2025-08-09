/* eslint-disable require-jsdoc */
import {admin} from "./admin";

// 定義 AppConfig 介面，確保資料類型安全
export interface AppConfig {
  default_name: string;
  name_max_length: number;
  price_modify_name: number;
  price_drink: number;
  price_simple_pray: number;
  price_advance_pray: number;
  kingdom_tasks: { [key: string]: KingdomTaskConfig };
  pray_pool: PrayPoolConfig;
}

// 定義單一任務的介面
export interface KingdomTaskConfig {
  text: string;
  limit: number;
  coin_reward: number;
  exp_reward: number;
  navigator: string;
}

// 祈禱池設定
export interface PrayPoolConfig {
  simple: PrayPoolEntry[];
  advance: PrayPoolEntry[];
}

// 單一祈禱池項目
export interface PrayPoolEntry {
  probability: number;
  rewards: PrayReward[];
}

// 單一獎勵項目
export interface PrayReward {
  type: string; // coin, exp, poop, drink...
  amount: number;
}

// 記憶體中的快取，用於儲存不同環境的配置
const configCache: { [key: string]: AppConfig | undefined } = {
  "dev_": undefined,
  "": undefined,
};

// 監聽狀態，避免重複設置監聽器
const listenerStatus: { [key: string]: boolean } = {
  "dev_": false,
  "": false,
};

/**
 * 將 Firestore 文件快照轉換為 AppConfig 物件。
 * @param {FirebaseFirestore.DocumentSnapshot} snapshot Firestore 文件快照。
 * @return {AppConfig | undefined} 轉換後的 AppConfig 物件，如果文件不存在則為 undefined。
 */
function toAppConfig(snapshot: FirebaseFirestore.DocumentSnapshot):
  AppConfig | undefined {
  if (!snapshot.exists) {
    return undefined;
  }
  const data = snapshot.data();
  if (!data) {
    return undefined;
  }

  // 處理 kingdom_tasks 欄位
  const tasks: { [key: string]: KingdomTaskConfig } = {};
  if (data.kingdomTasks && typeof data.kingdomTasks === "object") {
    for (const key in data.kingdomTasks) {
      if (Object.prototype.hasOwnProperty.call(data.kingdomTasks, key)) {
        tasks[key] = toKingdomTaskConfig(data.kingdomTasks[key]);
      }
    }
  }

  // prayPool
  let prayPool: PrayPoolConfig;
  if (data.prayPool && typeof data.prayPool === "object") {
    prayPool = toPrayPoolConfig(data.prayPool);
  } else {
    prayPool = {simple: [], advance: []};
  }

  // 執行類型檢查與轉換，並提供預設值
  return {
    default_name: (data.defaultName as string) ?? "未命名",
    name_max_length: (data.nameMaxLength as number) ?? 10,
    price_modify_name: (data.priceModifyName as number) ?? 100,
    price_drink: (data.priceDrink as number) ?? 75,
    price_simple_pray: (data.priceSimplePray as number) ?? 50,
    price_advance_pray: (data.priceAdvancePray as number) ?? 1,
    kingdom_tasks: tasks,
    pray_pool: prayPool,
  };
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
function toKingdomTaskConfig(data: any): KingdomTaskConfig {
  return {
    text: (data.text as string) ?? "",
    limit: (data.limit as number) ?? 1,
    coin_reward: (data.coin_reward as number) ?? 0,
    exp_reward: (data.exp_reward as number) ?? 0,
    navigator: (data.navigator as string) ?? "none",
  };
}

// PrayPool 轉換
// eslint-disable-next-line @typescript-eslint/no-explicit-any
function toPrayPoolConfig(data: any): PrayPoolConfig {
  return {
    simple: Array.isArray(data.simple) ? data.simple.map(toPrayPoolEntry) : [],
    // eslint-disable-next-line max-len
    advance: Array.isArray(data.advance) ? data.advance.map(toPrayPoolEntry) : [],
  };
}

// PrayPool 單一項目轉換
// eslint-disable-next-line @typescript-eslint/no-explicit-any
function toPrayPoolEntry(data: any): PrayPoolEntry {
  return {
    probability: (data.probability as number) ?? 0,
    rewards: Array.isArray(data.rewards) ? data.rewards.map(toPrayReward) : [],
  };
}

// PrayReward 單一獎勵轉換
// eslint-disable-next-line @typescript-eslint/no-explicit-any
function toPrayReward(data: any): PrayReward {
  return {
    type: (data.type as string) ?? "",
    amount: (data.amount as number) ?? 0,
  };
}


/**
 * 設置 Firestore 監聽器，並將配置儲存在記憶體中。
 * @param {string} prefix 集合前綴（'dev_' 或 ''）。
 */
function setupConfigListener(prefix: string): void {
  // 避免重複監聽
  if (listenerStatus[prefix]) {
    return;
  }
  listenerStatus[prefix] = true;

  const collectionName = `${prefix}config`;
  const docRef = admin.firestore().collection(collectionName).doc("main");

  docRef.onSnapshot(
    (snapshot) => {
      const config = toAppConfig(snapshot);
      configCache[prefix] = config;
      console.log(`[Config Module] ${collectionName}/main 已更新。`);
    },
    (error) => {
      console.error(`[Config Module] 監聽 ${collectionName}/main 失敗:`, error);
      listenerStatus[prefix] = false; // 發生錯誤時重置監聽狀態
    }
  );
}

/**
 * 取得指定環境的配置。
 * @param {string} prefix 集合前綴（'dev_' 或 ''）。
 * @return {Promise<AppConfig>} 配置物件的 Promise。
 * @throws {Error} 如果找不到配置。
 */
export async function fetchConfig(prefix: string): Promise<AppConfig> {
  // 當有人來呼叫 fetchConfig 時，如果監聽器尚未設置，就自動設置它
  if (!listenerStatus[prefix]) {
    console.log(`[Config Module] 正在為 ${prefix}config/main 設置監聽器...`);
    setupConfigListener(prefix);
  }

  // 從記憶體快取中取得配置
  let config = configCache[prefix];

  // 如果快取中沒有（表示這是第一次讀取，或監聽器剛設置還未收到資料），則等待一段時間
  // 或直接從 Firestore 讀取一次
  if (!config) {
    console.log(`[Config Module] 快取中沒有 ${prefix}config/main，嘗試讀取...`);
    const docRef = admin.firestore().collection(`${prefix}config`).doc("main");
    const snapshot = await docRef.get();
    config = toAppConfig(snapshot);
    configCache[prefix] = config; // 更新快取
  }

  // 檢查配置是否存在
  if (!config) {
    throw new Error(`找不到 ${prefix}config/main 的配置。`);
  }

  return config;
}
