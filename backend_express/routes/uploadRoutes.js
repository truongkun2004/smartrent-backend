const express = require("express");
const multer = require("multer");
const path = require("path");
const fs = require("fs");
const { v4: uuidv4 } = require("uuid");

const router = express.Router();
const IMAGES_DIR = path.join(process.cwd(), "images"); // thư mục images tại root project

// đảm bảo folder tồn tại
const ensureDir = (dir) => {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
};
ensureDir(IMAGES_DIR);

// multer in-memory
const storage = multer.memoryStorage();
const upload = multer({ storage }).array("images", 10); // limit 10 file (có thể chỉnh)

router.post("/upload", upload, (req, res) => {
  try {
    const files = req.files || [];
    if (files.length === 0) return res.status(400).json({ message: "Không có file nào được upload" });

    const resultNames = [];

    for (const file of files) {
      const originalName = file.originalname;
      const ext = path.extname(originalName) || "";
      const existingPath = path.join(IMAGES_DIR, originalName);

      // Nếu user re-upload đúng file đã có trong images (tên smartrent_...) -> không lưu, trả lại tên cũ
      if (originalName.startsWith("smartrent_") && fs.existsSync(existingPath)) {
        resultNames.push(originalName);
        continue;
      }

      // Ngược lại -> tạo tên mới, đảm bảo không trùng (độ trùng gần như 0 nhưng vẫn kiểm tra)
      let newName;
      do {
        newName = `smartrent_${uuidv4()}${ext}`;
      } while (fs.existsSync(path.join(IMAGES_DIR, newName)));

      // Ghi file từ buffer
      fs.writeFileSync(path.join(IMAGES_DIR, newName), file.buffer);
      resultNames.push(newName);
    }

    return res.status(200).json({ message: "Upload thành công", files: resultNames });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: "Lỗi upload file" });
  }
});

router.use("/images", express.static(path.join(process.cwd(), "images")));

module.exports = router;
