/* eslint-disable require-jsdoc */
/* eslint-disable max-len */
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {sendNotificationToUsers} from "./sendNotificationToUsers";
import {createNewPoopPricesFromAnnounce, createNewPoopPricesFromLatest} from "./createNewPoopPrices";
import {updatePropertyRecords, updateTradingAverageRecords} from "./updateRecords";

const REGION = "asia-east1";

// announce 觸發
export const onAnnounceCreated = onDocumentCreated({
  document: "announce/{uid}",
  region: REGION, // 可改成你要的地區
}, async (event) => {
  const data = event.data?.data();
  if (!data) return;
  await sendNotificationToUsers("", data);
  await createNewPoopPricesFromAnnounce("", data);
});

// dev_announce 觸發
export const onDevAnnounceCreated = onDocumentCreated({
  document: "dev_announce/{uid}",
  region: REGION, // 可改成你要的地區
}, async (event) => {
  const data = event.data?.data();
  if (!data) return;
  await sendNotificationToUsers("dev_", data);
  await createNewPoopPricesFromAnnounce("dev_", data);
});

// 🕒 每 20 分鐘觸發一次（你可以依需求修改 schedule）
export const scheduledPoopPricesCreation = onSchedule(
  {
    schedule: "every 30 minutes",
    region: REGION, // 你可以改成自己的區域
  },
  async () => {
    await createNewPoopPricesFromLatest("");
    await createNewPoopPricesFromLatest("dev_");
  }
);

export const onPricesCreated = onDocumentCreated({
  document: "prices/{id}",
  region: REGION, // 可改成你要的地區
}, async (event) => {
  const data = event.data?.data();
  if (!data) return;
  const buy = data["buy"];
  if (!buy || typeof buy != "number") return;
  // await updatePropertyRecords("", buy);
});

export const onDevPricesCreated = onDocumentCreated({
  document: "dev_prices/{id}",
  region: REGION, // 可改成你要的地區
}, async (event) => {
  const data = event.data?.data();
  if (!data) return;
  const buy = data["buy"];
  if (!buy || typeof buy != "number") return;
  await updatePropertyRecords("dev_", buy);
});

export const scheduledUpdateTradingAvgRecord = onSchedule(
  {
    schedule: "5 0,8,16 * * *",
    region: REGION, // 你可以改成自己的區域
  },
  async () => {
    // await updateTradingAverageRecords("");
    await updateTradingAverageRecords("dev_");
  }
);
