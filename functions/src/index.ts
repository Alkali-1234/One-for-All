// * ENV
import "dotenv/config";

import {onCall} from "firebase-functions/v2/https";
import * as functions from "firebase-functions";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import {FieldValue} from "firebase-admin/firestore";

// * OpenAI
import {OpenAI} from "openai";
const apiKey = process.env.OPENAI_API_KEY;
const openai = new OpenAI({apiKey: apiKey});

admin.initializeApp();

// * ------------------ MAB ------------------ *//
// Listen to firestore document changes at /communities/{communityId}/MAB/
export const onMABChange = functions.firestore.
  document("/communities/{communityId}/MAB/{docId}").
  onCreate((change, context) => {
    const document = change.data();
    logger.info("Document: ", document);
    if (document == null) return null;
    const type = document?.type;
    if (type == null) return null;
    // Send FCM notification
    const message = {
      notification: {
        title: `New ${type == 1? "Announcement" : "Task"}`,
        body: document?.title ?? "",
      },
      topic: `MAB_${context.params.communityId}`,
    };
    return admin.messaging().send(message).then((response) => {
      logger.info("Successfully sent message:", response);
      return response;
    }).catch((error) => {
      logger.error("Error sending message:", error);
      return error;
    });
  });

// * ------------------ LAC ------------------ *//
// Listen to firestore document changes at
// /communities/{communityId}/sections/{sectionId}/LAC/
export const onLACChange = functions.firestore.
  document("/communities/{communityId}/sections/{sectionId}/LAC/{docId}").
  onCreate((change, context) => {
    const document = change.data();
    if (document == null) return null;
    const type = document?.type;
    if (type == null) return null;
    // Send FCM notification
    const message = {
      notification: {
        title: `New ${type == 1? "Announcement" : "Task"}`,
        body: document?.title ?? "",
      },
      topic: `LAC_${context.params.communityId}_${context.params.sectionId}`,
    };
    return admin.messaging().send(message).then((response) => {
      logger.info("Successfully sent message:", response);
      return response;
    }
    ).catch((error) => {
      logger.error("Error sending message:", error);
      return error;
    }
    );
  });

// * ------------------ Community ------------------ *//
// * Join Community
export const joinCommunity = onCall(async (request) => {
  if (request.auth == null) {
    logger.error("Not authenticated");
    return "Not authenticated";
  }
  const uid = request.auth?.uid;
  const communityId = request.data.communityId;
  const password = request.data.password;
  const communityRef = admin.firestore().doc(`communities/${communityId}`);
  const userRef = admin.firestore().doc(`users/${uid}`);
  const batch = admin.firestore().batch();
  //* Check if password is correct
  const passwordSnapshot = await admin.firestore()
    .doc(`passwords/${communityId}`).get();
  if (!passwordSnapshot.exists) {
    logger.error("Community does not exist");
    return "Community does not exist";
  }
  if (passwordSnapshot.data()?.password != password) {
    logger.error("Wrong password");
    return "Wrog password";
  }
  // * Add user to community
  batch.update(communityRef, {
    members: FieldValue.arrayUnion(uid),
  });
  // * Change assigned community
  batch.update(userRef, {
    assignedCommunity: communityId,
  });
  const message = await batch.commit().then(() => {
    logger.info("Successfully joined community");
    return "Successfully joined community";
  }).catch((error) => {
    logger.error("Error joining community: ", error);
    return "Error joining community";
  });
  return message;
});

// * Leave Community
export const leaveCommunity = onCall(async (request) => {
  if (request.auth == null) {
    logger.error("Not authenticated");
    return "Not authenticated";
  }
  const uid = request.auth?.uid;
  const userRef = admin.firestore().doc(`users/${uid}`);
  const userData = await userRef.get();
  const communityId = await userData.data()?.assignedCommunity;
  const communityRef = admin.firestore().doc(`communities/${communityId}`);
  const batch = admin.firestore().batch();
  // * Remove user from community
  batch.update(communityRef, {
    members: FieldValue.arrayRemove(uid),
  });
  // * Change assigned community
  batch.update(userRef, {
    assignedCommunity: "",
  });
  const message = await batch.commit().then(() => {
    logger.info("Successfully left community");
    return "Successfully left community";
  }).catch((error) => {
    logger.error("Error leaving community: ", error);
    return "Error leaving community: " + error;
  });
  return message;
});

// * ------------------ Sections ------------------ *//
// * Join Section
export const joinSection = onCall(async (request) => {
  if (request.auth == null) {
    logger.error("Not authenticated");
    return "Not authenticated";
  }
  const uid = request.auth?.uid;
  const userRef = admin.firestore().doc(`users/${uid}`);
  const userData = await userRef.get();
  const communityId = userData.data()?.assignedCommunity;
  const sectionId = request.data.sectionId;
  const password = request.data.password;
  const sectionRef = admin.firestore()
    .doc(`communities/${communityId}/sections/${sectionId}`);
  const batch = admin.firestore().batch();
  // * Check if password is correct
  const passwordSnapshot =
    await admin.firestore()
      .doc(`passwords/${communityId}/sections/${sectionId}`).get();
  if (!passwordSnapshot.exists) {
    logger.error("Community does not exist");
    return "Community does not exist";
  }
  if (passwordSnapshot.data()?.password != password) {
    logger.error("Wrong password");
    return "Wrong password";
  }
  // * Add user to section
  batch.update(sectionRef, {
    members: FieldValue.arrayUnion(uid),
  });
  // * Change assigned section
  batch.update(userRef, {
    sections: FieldValue.arrayUnion(sectionId),
  });
  const message = await batch.commit().then(() => {
    logger.info("Successfully joined section");
    return "Successfully joined section";
  }).catch((error) => {
    logger.error("Error joining section: ", error);
    return "Error joining section" + error;
  });
  return message;
});

// * Leave Section
export const leaveSection = onCall(async (request) => {
  if (request.auth == null) {
    logger.error("Not authenticated");
    return "Not authenticated";
  }
  const uid = request.auth?.uid;
  const userRef = admin.firestore().doc(`users/${uid}`);
  const userData = await userRef.get();
  const communityId = userData.data()?.assignedCommunity;
  const sectionId = request.data.sectionId;
  const sectionRef = admin.firestore()
    .doc(`communities/${communityId}/sections/${sectionId}`);
  const batch = admin.firestore().batch();
  // * Remove user from section
  batch.update(sectionRef, {
    members: FieldValue.arrayRemove(uid),
  });
  // * Change assigned section
  batch.update(userRef, {
    sections: FieldValue.arrayRemove(sectionId),
  });
  const message = await batch.commit().then(() => {
    logger.info("Successfully left section");
    return "Successfully left section";
  }).catch((error) => {
    logger.error("Error leaving section: ", error);
    return "Error leaving section" + error;
  });
  return message;
});

// * ------------------ OpenAI ------------------ *//
export const generateQuiz = onCall(async (request) => {
  if (request.auth == null) {
    logger.error("Not authenticated");
    return "Not authenticated";
  }
  const messages = request.data.messages;
  const assistant =
    await openai.beta.assistants.retrieve("asst_EqKF2EwRB7waTZgfH3mfdQh8");
  const thread = await openai.beta.threads.create({
    messages: messages,
  });

  const run = await openai.beta.threads.runs.createAndPoll(
    thread.id,
    {assistant_id: assistant.id}
  );

  if (run.status === "completed") {
    logger.info("Quiz generated: ", run, openai
      .beta.threads.messages.list(thread.id));
    return (await openai.beta.threads.messages.list(thread.id)).data;
  } else {
    logger.error("Error generating quiz: ", run);
    return run;
  }
});
