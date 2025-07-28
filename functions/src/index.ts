/* eslint-disable require-jsdoc */
/* eslint-disable max-len */
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {sendNotificationToUsers} from "./sendNotificationToUsers";

// announce 觸發
export const onAnnounceCreated = onDocumentCreated({
  document: "announce/{uid}",
  region: "asia-east2", // 可改成你要的地區
}, (event) => {
  const data = event.data?.data();
  if (!data) return;
  return sendNotificationToUsers("", data);
});

// dev_announce 觸發
export const onDevAnnounceCreated = onDocumentCreated({
  document: "dev_announce/{uid}",
  region: "asia-east2", // 可改成你要的地區
}, (event) => {
  const data = event.data?.data();
  if (!data) return;
  return sendNotificationToUsers("dev_", data);
});
