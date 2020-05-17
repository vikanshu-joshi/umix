const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();

exports.onCreateFollower = functions.firestore
    .document("/users/{userId}/friends/{friendId}")
    .onCreate(async (snap, context) => {
        const userId = context.params.userId;
        const friendId = context.params.friendId;

        const myPosts = admin.firestore().collection("posts").doc(userId).collection("userPosts");
        const friendPosts = admin.firestore().collection("posts").doc(friendId).collection("userPosts");

        const myTimeline = admin.firestore().collection("users").doc(userId).collection("timeline");
        const friendTimeline = admin.firestore().collection("users").doc(friendId).collection("timeline");

        const queryMyPosts = await myPosts.get();
        queryMyPosts.forEach(doc => {
            if (doc.exists) {
                const id = doc.id;
                const data = doc.data();
                friendTimeline.doc(id).set(data);
            }
        });

    });

exports.onDeleteFriend = functions.firestore
    .document("/users/{userId}/friends/{friendId}")
    .onDelete(async (snap, context) => {
        const userId = context.params.userId;
        const friendId = context.params.friendId;
        const myTimeline = admin.firestore().collection("users").doc(userId).collection("timeline")
            .where("owner", "==", friendId);
        const friendTimeline = admin.firestore().collection("users").doc(friendId).collection("timeline");

        const query = await myTimeline.get();
        query.forEach(doc => {
            if (doc.exists) {
                doc.ref.delete();
            }
        });
    });


exports.onCreatePost = functions.firestore
    .document("posts/{userId}/userPosts/{postId}")
    .onCreate(async (snap, context) => {
        const post = snap.data();
        const postId = context.params.postId;
        const userId = context.params.userId;

        const userFriends = admin.firestore().collection("users").doc(userId).collection("friends");

        const query = await userFriends.get();
        query.forEach(doc => {
            const friendId = doc.id;
            admin.firestore().collection("users").doc(friendId).collection("timeline").doc(postId).set(post);
        });
    });

exports.onPostUpdated = functions.firestore
    .document("posts/{userId}/userPosts/{postId}")
    .onUpdate(async (change, context) => {
        const post = change.after.data();
        const postId = context.params.postId;
        const userId = context.params.userId;
        const userFriends = admin.firestore().collection("users").doc(userId).collection("friends");

        const query = await userFriends.get();

        query.forEach(doc => {
            const friendId = doc.id;
            admin
                .firestore()
                .collection("users").doc(friendId)
                .collection("timeline").doc(postId)
                .get().then(doc => {
                    if(doc.exists){
                        doc.ref.update(post);
                    }
                });
        });
    });


exports.newNotification = functions.firestore
    .document("/users/{userId}/notifications/{notificationId}")
    .onCreate(async (snap, context) => {
        const userId = context.params.userId;
        const notificationId = context.params.notificationId;
        const userRef = admin.firestore().doc(`/users/${userId}`);
        const doc = await userRef.get();
        const androidNotificationToken = doc.data().androidNotificationToken;

        if (androidNotificationToken) {
             const data = snap.data();
             var body = `${data.name} sent you a new message`;
             const message = {
                "notification": { "body" : "","title" : body },
                "token": androidNotificationToken,
                "data": {
                    "id": `${data.id}`,
                    "image": `${data.image}`,
                    "data": `${data.data}`,
                    "name": `${data.name}`,
                    "type": `${data.type}`,
                }
             };
             admin.messaging().send(message).then(onvalue => {
                console.log("Sent notification",onvalue);
             }).catch(error => {
                console.log("error sending notification",error);
             });
        } else {
            console.log("No token for user");
        }
    });