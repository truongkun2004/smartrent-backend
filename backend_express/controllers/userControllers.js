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

const toggleFavorite = async (req, res) => {
  const { userId, propertyId } = req.body;
  try {
    const action = await userServices.toggleUserFavorite(userId, propertyId);
    res.json({ message: `Favorite ${action} successfully.`, action });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const getFavorites = async (req, res) => {
  const { userId } = req.params;
  try {
    const favorites = await userServices.getUserFavorites(userId);
    res.status(200).json(favorites);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

async function addReview(req, res) {
    try {
        const { propertyId, userId, rating, comment } = req.body;
        await userServices.addPropertyReview(propertyId, userId, rating, comment);
        res.status(201).json({ message: "Review added successfully" });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Internal server error" });
    }
}

module.exports = {
  addUser,
  updateUser,
  deleteUser,
  loginUser,
  toggleFavorite,
  getFavorites,
  addReview,
};
