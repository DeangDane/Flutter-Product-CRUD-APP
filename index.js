const express = require("express");
const dotenv = require("dotenv");
const cors = require("cors");
const productRoutes = require("./routes/products");

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());
app.use("/products", productRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server started on port ${PORT}`));
