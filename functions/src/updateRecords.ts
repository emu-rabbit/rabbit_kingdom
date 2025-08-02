/* eslint-disable require-jsdoc */
import * as admin from "firebase-admin";
import {getCurrentMonthKey, limitConcurrency} from "./utils";

const MAX_BATCH_SIZE = 200;
const MAX_CONCURRENCY = 5;

export async function updatePropertyRecords(
  prefix: string, buy: number
) {
  const db = admin.firestore();
  const userCollection = db.collection(`${prefix}user`);
  const recordsCollection = db.collection(`${prefix}records`);

  const snapshot = await userCollection.where("group", "!=", "unknown").get();
  const docs = snapshot.docs;

  const chunks: FirebaseFirestore.QueryDocumentSnapshot[][] = [];
  for (let i = 0; i < docs.length; i += MAX_BATCH_SIZE) {
    chunks.push(docs.slice(i, i + MAX_BATCH_SIZE));
  }

  const tasks = chunks.map((chunk) => {
    return () => processChunk(
      chunk, db, recordsCollection, buy, getCurrentMonthKey()
    );
  });

  await limitConcurrency(tasks, MAX_CONCURRENCY);
  console.log(`✅ 已更新 ${docs.length} 位使用者的資產紀錄（分批 ${chunks.length} 組）`);
}

async function processChunk(
  chunk: FirebaseFirestore.QueryDocumentSnapshot[],
  db: FirebaseFirestore.Firestore,
  recordsCollection: FirebaseFirestore.CollectionReference,
  buy: number,
  monthKey: string
) {
  const batch = db.batch();

  const recordSnaps = await getDocsByMultipleIds(
    recordsCollection,
    chunk.map((c) => c.id)
  );

  chunk.forEach((userDoc, i) => {
    const uid = userDoc.id;
    const userData = userDoc.data();
    const recordData = recordSnaps[i].exists ? recordSnaps[i].data() ?? {} : {};

    const budget = userData.budget ?? {};
    const coin = Number(budget.coin ?? 0);
    const poop = Number(budget.poop ?? 0);
    const currentTotal = coin + poop * buy;

    const prevTotal = recordData.property?.all?.value ?? 0;
    const growth = currentTotal - prevTotal;
    const currentMonthValue = recordData.property?.[monthKey]?.value ?? 0;

    const recordRef = recordsCollection.doc(uid);
    batch.set(recordRef, {
      property: {
        all: {
          value: currentTotal,
        },
        [monthKey]: {
          value: currentMonthValue + growth,
        },
      },
    }, {merge: true});
  });

  await batch.commit();
}

async function getDocsByMultipleIds(
  collectionRef: FirebaseFirestore.CollectionReference,
  ids: string[],
  batchSize = 10
// eslint-disable-next-line max-len
): Promise<FirebaseFirestore.DocumentSnapshot<FirebaseFirestore.DocumentData>[]> {
  if (ids.length === 0) {
    return [];
  }

  const allQueries: Promise<FirebaseFirestore.QuerySnapshot>[] = [];

  // 將 IDs 陣列分割成小批次
  for (let i = 0; i < ids.length; i += batchSize) {
    const batchIds = ids.slice(i, i + batchSize);

    // 對每個小批次建立一個查詢
    const query = collectionRef
      .where(admin.firestore.FieldPath.documentId(), "in", batchIds).get();
    allQueries.push(query);
  }

  // 使用 Promise.all() 平行執行所有查詢
  const allSnapshots = await Promise.all(allQueries);

  // 將所有查詢結果合併成一個單一的快照陣列
  const allDocs: FirebaseFirestore.DocumentSnapshot[] = [];
  allSnapshots.forEach((snapshot) => {
    allDocs.push(...snapshot.docs);
  });

  return allDocs;
}
