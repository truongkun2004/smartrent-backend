require("dotenv").config();
const express = require("express");
const { connectDB } = require("./config/database");

const app = express();
const PORT = process.env.PORT || 5000;

app.use(express.json());

const propertyTypeRoutes = require("./routes/propertyTypeRoutes");
const amenityRoutes = require("./routes/amenityRoutes");
const hostRoutes = require("./routes/hostRoutes");
const uploadRoutes = require("./routes/uploadRoutes");
const propertyRoutes = require("./routes/propertyRoutes");

app.use("/api/property-types", propertyTypeRoutes);
app.use("/api/amenities", amenityRoutes);
app.use("/api/hosts", hostRoutes);
app.use("/api", uploadRoutes);
app.use("/api/properties", propertyRoutes);

app.get("/", (req, res) => {
  res.send("🚀 Express server is running...");
});

connectDB().then(() => {
  app.listen(PORT, () => {
    console.log(`✅ Server is running at http://localhost:${PORT}`);
  });
});
