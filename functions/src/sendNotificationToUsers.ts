/* eslint-disable max-len */
/* eslint-disable require-jsdoc */
import {TokenMessage} from "firebase-admin/lib/messaging/messaging-api";
import {limitConcurrency} from "./utils";
import {logger} from "firebase-functions";
import {admin} from "./admin";

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export async function sendNotificationToUsers(prefix: string, data: Record<string, any>) {
  const snapshot = await admin.firestore()
    .collection(`${prefix}fcm`)
    .get();
  const docs = snapshot.docs.map(
    (doc) => ({
      id: doc.id,
      token: doc.data()["token"] ?? "",
    })
  ).filter((doc) => doc.token !== "");

  const sticker = typeof data["sticker"] === "string" && data["sticker"] ? data["sticker"] : "tired";
  const mood = typeof data["mood"] === "number" ? data["mood"] : 0;
  const display = (() => {
    switch (sticker) {
    case "happy": return "開心";
    case "angry": return "生氣";
    case "sad": return "傷心";
    case "tired": return "疲累";
    case "excited": return "激動";
    case "shy": return "害羞";
    case "cool": return "酷";
    default: return "疲累";
    }
  })();

  await limitConcurrency(
    docs.map((doc) => async () => {
      const message: TokenMessage = {
        token: doc.token,
        notification: {
          title: "兔兔大帝發公告拉",
          body: `兔兔現在心情很${display}，心情指數${mood}`,
          imageUrl: `https://rabbit-kingdom-2759a.web.app/assets/lib/assets/images/sticker_${sticker}.png`,
        },
      };
      try {
        await admin.messaging().send(message);
      } catch (error) {
        logger.error(`Failed to send message to token ${doc.token}:`, error);
      }
    }),
    5 // 你可以調整這個併發數量
  );
  console.log(`Send notifications to ${docs.length} users in ${prefix} `);
}
