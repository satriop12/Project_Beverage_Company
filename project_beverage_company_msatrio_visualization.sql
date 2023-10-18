-- Mencari Descripsion yang tidak terjual

WITH barang_awal_tahun AS (
  SELECT beginning_inv.InventoryId, beginning_inv.Description,SUM(beginning_inv.onHand) AS total_barang_awal
  FROM beginning_inventory AS beginning_inv
  GROUP BY 1,2
),
pembelian_barang_purchase AS (
  SELECT purchase.InventoryId, purchase.Description,SUM(purchase.Quantity) AS total_pembelian
  FROM purchases AS purchase
  GROUP BY 1,2
),

tabela as (
  select * from barang_awal_tahun
  union all
  select * from pembelian_barang_purchase
),

inventory_after_purchase as (
  select InventoryId, Description, sum(total_barang_awal) as inventory_gudang
  from tabela
  group by 1, 2
),

data_penjualan as (
SELECT
    sales.InventoryId, sales.Description,
    SUM(SalesQuantity) AS total_penjualan
  FROM sales AS sales
  GROUP BY 1,2
), 


barang_sisa as (
  select z.InventoryId, z.Description ,z.inventory_gudang, COALESCE(c.total_penjualan,0) as total_penjualan, (z.inventory_gudang-COALESCE(c.total_penjualan,0)) as sisa_stok
  from inventory_after_purchase as z
  left join data_penjualan as c on z.InventoryId = c.InventoryId
),


tidak_terjual as (
select iap.InventoryId, iap.Description , iap.inventory_gudang, bs.sisa_stok
from inventory_after_purchase as iap 
left join barang_sisa as bs 
on iap.InventoryId = bs.InventoryId 
where iap.inventory_gudang = bs.sisa_stok
)
-- -- Barang tidak terjual deskripsi
-- select Description, sum(sisa_stok) as barang_tidak_terjual
-- from tidak_terjual
-- where tidak_terjual.sisa_stok <> 0
-- group by 1
-- order by barang_tidak_terjual DESC

-- -- Barang tidak terjual InventoryId
-- select InventoryId, sum(sisa_stok) as barang_tidak_terjual
-- from tidak_terjual
-- where tidak_terjual.sisa_stok <> 0 
-- group by 1
-- order by barang_tidak_terjual DESC

-- penjualan terbanyak per toko
select cast(SPLIT(InventoryId, '_')[SAFE_OFFSET(0)] as string) AS store_name, SUM(SalesDollars) AS total_penjualan
FROM sales
group by 1
order by 2 desc

-- -- penjualan terbanyak per kota
-- SELECT
--   SPLIT(InventoryId, '_')[SAFE_OFFSET(1)] AS city, SUM(SalesDollars) AS total_penjualan
-- FROM
--   sales
-- group by 1
-- order by 2 desc

