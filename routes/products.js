const express = require("express");
const router = express.Router();
const { poolPromise, sql } = require("../db");

// Helper: validation
function validateProduct(data) {
  if (!data.PRODUCTNAME || data.PRODUCTNAME.trim() === '') return 'Product name is required';
  if (typeof data.PRICE !== 'number' || data.PRICE <= 0) return 'Price must be positive number';
  if (typeof data.STOCK !== 'number' || data.STOCK < 0) return 'Stock must be zero or positive number';
  return null;
}

// GET all products or single by id
router.get("/", async (req, res) => {
  try {
    const pool = await poolPromise;
    const { search, sort, order, page, limit, id } = req.query;

    // Get single product by ID
    if (id) {
      const result = await pool.request()
        .input('id', sql.Int, id)
        .query('SELECT * FROM PRODUCTS WHERE PRODUCTID = @id');
      if (result.recordset.length === 0) return res.status(404).json({ message: 'Product not found' });
      return res.json(result.recordset[0]);
    }

    let baseQuery = 'SELECT * FROM PRODUCTS';
    let countQuery = 'SELECT COUNT(*) AS total FROM PRODUCTS';
    const where = [];
    const reqSql = pool.request();

    if (search) {
      where.push('PRODUCTNAME LIKE @search');
      reqSql.input('search', sql.NVarChar, `%${search}%`);
    }

    // Apply WHERE clause if needed
    if (where.length) {
      baseQuery += ' WHERE ' + where.join(' AND ');
      countQuery += ' WHERE ' + where.join(' AND ');
    }

    // Sorting
    if (sort && ['PRICE', 'STOCK'].includes(sort.toUpperCase())) {
      baseQuery += ` ORDER BY ${sort.toUpperCase()} ${order?.toUpperCase() === 'DESC' ? 'DESC' : 'ASC'}`;
    } else {
      baseQuery += ` ORDER BY PRODUCTID ASC`;
    }

    // Pagination
    const pageNum = parseInt(page) || 1;
    const pageSize = parseInt(limit) || 10;
    const offset = (pageNum - 1) * pageSize;

    reqSql.input('offset', sql.Int, offset);
    reqSql.input('limit', sql.Int, pageSize);

    baseQuery += ` OFFSET @offset ROWS FETCH NEXT @limit ROWS ONLY`;

    // Execute both paginated + count queries
    const data = await reqSql.query(baseQuery);
    const count = await pool.request().query(countQuery);

    return res.json({
      products: data.recordset,
      totalCount: count.recordset[0].total,
      totalPages: Math.ceil(count.recordset[0].total / pageSize),
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST create
router.post("/", async (req, res) => {
  try {
    const { PRODUCTNAME, PRICE, STOCK } = req.body;
    const errMsg = validateProduct({ PRODUCTNAME, PRICE, STOCK });
    if (errMsg) return res.status(400).json({ message: errMsg });

    const pool = await poolPromise;
    const result = await pool.request()
      .input('PRODUCTNAME', sql.NVarChar(100), PRODUCTNAME)
      .input('PRICE', sql.Decimal(10, 2), PRICE)
      .input('STOCK', sql.Int, STOCK)
      .query('INSERT INTO PRODUCTS (PRODUCTNAME, PRICE, STOCK) OUTPUT INSERTED.* VALUES (@PRODUCTNAME, @PRICE, @STOCK)');
    res.status(201).json(result.recordset[0]);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// PUT update
router.put("/", async (req, res) => {
  try {
    const { id } = req.query;
    const { PRODUCTNAME, PRICE, STOCK } = req.body;
    if (!id) return res.status(400).json({ message: 'Product id is required' });
    const errMsg = validateProduct({ PRODUCTNAME, PRICE, STOCK });
    if (errMsg) return res.status(400).json({ message: errMsg });

    const pool = await poolPromise;
    const result = await pool.request()
      .input('id', sql.Int, id)
      .input('PRODUCTNAME', sql.NVarChar(100), PRODUCTNAME)
      .input('PRICE', sql.Decimal(10, 2), PRICE)
      .input('STOCK', sql.Int, STOCK)
      .query('UPDATE PRODUCTS SET PRODUCTNAME=@PRODUCTNAME, PRICE=@PRICE, STOCK=@STOCK WHERE PRODUCTID=@id; SELECT * FROM PRODUCTS WHERE PRODUCTID=@id');
    if (result.recordset.length === 0) return res.status(404).json({ message: 'Product not found' });
    res.json(result.recordset[0]);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// DELETE
router.delete("/", async (req, res) => {
  try {
    const { id } = req.query;
    if (!id) return res.status(400).json({ message: 'Product id is required' });

    const pool = await poolPromise;
    const result = await pool.request()
      .input('id', sql.Int, id)
      .query('DELETE FROM PRODUCTS WHERE PRODUCTID=@id');
    if (result.rowsAffected[0] === 0) return res.status(404).json({ message: 'Product not found' });

    res.json({ message: 'Deleted successfully' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;