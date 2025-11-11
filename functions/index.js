const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const nodemailer = require("nodemailer");

const app = express();
app.use(cors());
app.use(bodyParser.json());

// ✅ Cấu hình Gmail transporter
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "522H0172@student.tdtu.edu.vn", // gmail bạn dùng để gửi
    pass: "rjdt dzys ywnn udvv",        // app password bạn tạo
  },
});

// ✅ Route API gửi mail
app.post("/send-mail", async (req, res) => {
  const { email, name } = req.body; // Flutter gửi name, email người đăng ký

  if (!email) {
    return res.status(400).json({ success: false, message: "Thiếu email!" });
  }

  try {
    const info = await transporter.sendMail({
      from: '"GG Classroom" <522H0172@student.tdtu.edu.vn>',
      to: email,
      subject: "Đăng ký tài khoản thành công 🎉",
      text: `Xin chào ${name || ""}! Bạn đã đăng ký thành công tài khoản GG Classroom.`,
    });

    console.log("✅ Đã gửi mail:", info.messageId);
    res.json({ success: true });
  } catch (err) {
    console.error("❌ Lỗi gửi mail:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// ✅ Chạy server cục bộ
const PORT = 5000;
app.listen(PORT, () => {
  console.log(`🚀 Server đang chạy tại http://localhost:${PORT}`);
});