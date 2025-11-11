import nodemailer from "nodemailer";

export default async function handler(req, res) {
  // ✅ Cho phép request từ mọi nguồn (hoặc chỉ từ domain Flutter của bạn)
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") {
    // Trả về 200 cho preflight request
    res.status(200).end();
    return;
  }

  if (req.method !== "POST") {
    res.status(405).json({ error: "Method not allowed" });
    return;
  }

  const { email, name } = req.body;

  if (!email || !name) {
    res.status(400).json({ error: "Missing email or name" });
    return;
  }

  try {
    const transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: process.env.GMAIL_USER,
        pass: process.env.GMAIL_PASS
      }
    });

    await transporter.sendMail({
      from: process.env.GMAIL_USER,
      to: email,
      subject: "Chúc mừng đăng ký thành công",
      text: `Chào ${name},\nCảm ơn bạn đã đăng ký!`
    });

    res.status(200).json({ message: "Email sent successfully!" });
  } catch (err) {
    console.error("Failed to send email:", err);
    res.status(500).json({ error: err.message });
  }
}
