/* eslint-disable require-jsdoc */
/* eslint-disable max-len */
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {sendAnnounceNotification, sendNewsNotification} from "./sendNotificationToUsers";
import {createNewPoopPricesFromAnnounce, createNewPoopPricesFromLatest} from "./createNewPoopPrices";
import {updateRanks} from "./updateRanks";

const REGION = "asia-east1";

// announce 觸發
export const onAnnounceCreated = onDocumentCreated({
  document: "announce/{uid}",
  region: REGION, // 可改成你要的地區
}, async (event) => {
  const data = event.data?.data();
  if (!data) return;
  await sendAnnounceNotification("", data);
  await createNewPoopPricesFromAnnounce("", data);
});

// dev_announce 觸發
export const onDevAnnounceCreated = onDocumentCreated({
  document: "dev_announce/{uid}",
  region: REGION, // 可改成你要的地區
}, async (event) => {
  const data = event.data?.data();
  if (!data) return;
  await sendAnnounceNotification("dev_", data);
  await createNewPoopPricesFromAnnounce("dev_", data);
});

// news 觸發
export const onNewsCreated = onDocumentCreated({
  document: "news/{uid}",
  region: REGION, // 可改成你要的地區
}, async (event) => {
  const data = event.data?.data();
  if (!data) return;
  await sendNewsNotification("", data);
});

// dev_news 觸發
export const onDevNewsCreated = onDocumentCreated({
  document: "dev_news/{uid}",
  region: REGION, // 可改成你要的地區
}, async (event) => {
  const data = event.data?.data();
  if (!data) return;
  await sendNewsNotification("dev_", data);
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

export const scheduledUpdateRanks = onSchedule(
  {
    schedule: "55 3,7,11,15,19,23 * * *",
    region: REGION, // 你可以改成自己的區域
  },
  async () => {
    await updateRanks("");
    await updateRanks("dev_");
  }
);
