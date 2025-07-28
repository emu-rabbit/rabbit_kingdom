/* eslint-disable require-jsdoc */
/* eslint-disable max-len */
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {sendNotificationToUsers} from "./sendNotificationToUsers";
import {createNewPoopPricesFromAnnounce, createNewPoopPricesFromLatest} from "./createNewPoopPrices";

// announce 觸發
export const onAnnounceCreated = onDocumentCreated({
  document: "announce/{uid}",
  region: "asia-east2", // 可改成你要的地區
}, async (event) => {
  const data = event.data?.data();
  if (!data) return;
  await sendNotificationToUsers("", data);
  await createNewPoopPricesFromAnnounce("", data);
});

// dev_announce 觸發
export const onDevAnnounceCreated = onDocumentCreated({
  document: "dev_announce/{uid}",
  region: "asia-east2", // 可改成你要的地區
}, async (event) => {
  const data = event.data?.data();
  if (!data) return;
  await sendNotificationToUsers("dev_", data);
  await createNewPoopPricesFromAnnounce("dev_", data);
});

// 🕒 每 20 分鐘觸發一次（你可以依需求修改 schedule）
export const scheduledPoopPricesCreation = onSchedule(
  {
    schedule: "every 20 minutes",
    region: "asia-east2", // 你可以改成自己的區域
  },
  async () => {
    await createNewPoopPricesFromLatest("");
    await createNewPoopPricesFromLatest("dev_");
  }
);
