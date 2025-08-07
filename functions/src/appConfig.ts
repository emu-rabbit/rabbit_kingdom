import {admin} from "./admin";

// 定義 AppConfig 介面，確保資料類型安全
export interface AppConfig {
  default_name: string;
  name_max_length: number;
  price_modify_name: number;
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
  // 執行類型檢查與轉換，並提供預設值
  return {
    default_name: data.defaultName || "未命名",
    name_max_length: data.nameMaxLength || 10,
    price_modify_name: data.priceModifyName || 100,
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
