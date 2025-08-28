const hostServices = require("../services/hostServices");
const bcrypt = require("bcryptjs");

async function addHost(req, res) {
  try {
    let { password, ...rest } = req.body;

    if (password) {
      const salt = await bcrypt.genSalt(10);
      password = await bcrypt.hash(password, salt);
    }

    const newHost = await hostServices.addHost({ ...rest, password });
    res.status(201).json({ message: "Thêm host thành công", data: newHost });
  } catch (err) {
    res.status(500).json({ message: "Lỗi khi thêm host", error: err.message });
  }
}

async function updateHost(req, res) {
  try {
    await hostServices.updateHost({ id: req.params.id, ...req.body });
    res.status(200).json({ message: "Cập nhật host thành công" });
  } catch (err) {
    res.status(500).json({ message: "Lỗi khi cập nhật host", error: err.message });
  }
}

async function deleteHost(req, res) {
  try {
    await hostServices.deleteHost(req.params.id);
    res.status(200).json({ message: "Xóa host thành công" });
  } catch (err) {
    res.status(500).json({ message: "Lỗi khi xóa host", error: err.message });
  }
}

async function loginHost(req, res) {
  try {
    const { firebase_id, account, password } = req.body;

    const host = await hostServices.findHost({ firebase_id, account });

    if (!host) {
      return res.status(404).json({ message: "Host không tồn tại" });
    }

    if (firebase_id) {
      // Đăng nhập bằng Firebase ID -> trả thẳng thông tin
      return res.status(200).json({
        message: "Đăng nhập Firebase thành công",
        data: {
          id: host.id,
          name: host.name,
          created_at: host.created_at,
        },
      });
    } else {
      // Đăng nhập bằng account + password
      const isMatch = await bcrypt.compare(password, host.password);
      if (!isMatch) {
        return res.status(401).json({ message: "Sai mật khẩu" });
      }

      return res.status(200).json({
        message: "Đăng nhập thành công",
        data: {
          id: host.id,
          name: host.name,
          created_at: host.created_at,
        },
      });
    }
  } catch (err) {
    res.status(500).json({ message: "Lỗi khi đăng nhập host", error: err.message });
  }
}

async function getHostProperties(req, res) {
  try {
    const { id } = req.params;
    const data = await hostServices.getHostProperties(id);

    res.status(200).json(data); // trả trực tiếp list
  } catch (err) {
    res.status(500).json({ message: "Lỗi khi lấy properties", error: err.message });
  }
}

async function depositToHost(req, res) {
  try {
    const { hostId, amount } = req.body;
    if (!hostId || !amount) {
      return res.status(400).json({ message: "hostId và amount là bắt buộc" });
    }

    await hostServices.depositToHost({ hostId, amount });
    res.status(200).json({ message: "Nạp tiền thành công" });
  } catch (err) {
    res.status(500).json({ message: "Lỗi khi nạp tiền", error: err.message });
  }
}

module.exports = {
  addHost,
  updateHost,
  deleteHost,
  loginHost,
  getHostProperties,
  depositToHost,
};