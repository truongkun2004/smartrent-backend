const userServices = require("../services/userServices");
const bcrypt = require("bcryptjs");

async function addUser(req, res) {
  try {
    const { name, phone, email, password, firebase_id } = req.body;

    const hashedPassword = password ? await bcrypt.hash(password, 10) : null;

    const newUser = await userServices.addUser({
      name,
      phone,
      email,
      password: hashedPassword,
      firebase_id,
    });

    res.status(201).json({
      message: "Thêm user thành công",
      data: newUser,
    });
  } catch (err) {
    res.status(500).json({ message: "Lỗi khi thêm user", error: err.message });
  }
}

async function updateUser(req, res) {
  try {
    const { id } = req.params;
    const { name, phone, email } = req.body;

    await userServices.updateUser({ id, name, phone, email });

    res.status(200).json({ message: "Cập nhật user thành công" });
  } catch (err) {
    res.status(500).json({ message: "Lỗi khi cập nhật user", error: err.message });
  }
}

async function deleteUser(req, res) {
  try {
    const { id } = req.params;
    await userServices.deleteUser(id);

    res.status(200).json({ message: "Xóa user thành công" });
  } catch (err) {
    res.status(500).json({ message: "Lỗi khi xóa user", error: err.message });
  }
}

async function loginUser(req, res) {
  try {
    const { firebase_id, account, password } = req.body;

    const users = await userServices.findUser({ firebase_id, account });
    const user = users && users.length > 0 ? users[0] : null;

    if (!user) {
      return res.status(404).json({ message: "User không tồn tại" });
    }

    if (firebase_id) {
      return res.status(200).json({
        message: "Đăng nhập Firebase thành công",
        data: {
          id: user.id,
          name: user.name,
          created_at: user.created_at,
        },
      });
    } else {
      const isMatch = await bcrypt.compare(password, user.password);
      if (!isMatch) {
        return res.status(401).json({ message: "Sai mật khẩu" });
      }

      return res.status(200).json({
        message: "Đăng nhập thành công",
        data: {
          id: user.id,
          name: user.name,
          created_at: user.created_at,
        },
      });
    }
  } catch (err) {
    res.status(500).json({ message: "Lỗi khi đăng nhập user", error: err.message });
  }
}

module.exports = {
  addUser,
  updateUser,
  deleteUser,
  loginUser,
};
