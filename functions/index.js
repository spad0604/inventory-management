const functions = require("firebase-functions");
const admin = require("firebase-admin");
const moment = require("moment");

admin.initializeApp();

exports.checkExpiryDates = functions.pubsub.schedule("every 1 minutes").onRun(async (context) => {
    const db = admin.database();
    const productsRef = db.ref(); // Truy cập toàn bộ database gốc.

    const snapshot = await productsRef.once("value");
    const now = moment(); // Lấy thời gian hiện tại.

    // Lặp qua từng sản phẩm trong database
    snapshot.forEach((childSnapshot) => {
        const key = childSnapshot.key;
        const product = childSnapshot.val();
        
        if (product.expiry) {
            try {
                const expiryDate = moment(product.expiry, "DD/MM/YYYY");
                const timeLeft = expiryDate.diff(now, "hours");

                // Kiểm tra sản phẩm đã hết hạn
                if (timeLeft < 0) {
                    const daysExpired = Math.abs(Math.floor(timeLeft / 24));
                    const payload = {
                        notification: {
                            title: "Sản phẩm đã hết hạn!",
                            body: `${product.productName} (kệ ${product.className}, vị trí ${product.order}) đã hết hạn ${daysExpired} ngày!`,
                        },
                        data: {
                            productId: key,
                            className: product.className,
                            order: product.order.toString()
                        }
                    };
                    admin.messaging().sendToTopic("expiry_notifications", payload)
                        .then(() => console.log(`Đã gửi thông báo hết hạn cho ${key}: ${product.productName}`))
                        .catch((error) => console.error("Lỗi gửi thông báo:", error));
                }
                // Kiểm tra sản phẩm sắp hết hạn (trong vòng 10 ngày)
                else if (timeLeft > 0 && timeLeft <= 240) {
                    const daysLeft = Math.ceil(timeLeft / 24);
                    const payload = {
                        notification: {
                            title: "Cảnh báo sắp hết hạn!",
                            body: `${product.productName} (kệ ${product.className}, vị trí ${product.order}) sẽ hết hạn trong ${daysLeft} ngày!`,
                        },
                        data: {
                            productId: key,
                            className: product.className,
                            order: product.order.toString()
                        }
                    };
                    admin.messaging().sendToTopic("expiry_notifications", payload)
                        .then(() => console.log(`Đã gửi thông báo sắp hết hạn cho ${key}: ${product.productName}`))
                        .catch((error) => console.error("Lỗi gửi thông báo:", error));
                }
            } catch (error) {
                console.error(`Lỗi xử lý ngày hết hạn cho sản phẩm ${key}:`, error);
            }
        }
    });

    return null;
});
