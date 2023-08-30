WITH barang_awal_tahun AS (
  SELECT beginning_inv.InventoryId, SUM(beginning_inv.onHand) AS total_barang_awal
  FROM beginning_inventory AS beginning_inv
  GROUP BY beginning_inv.InventoryId
),
pembelian_barang_purchase AS (
  SELECT purchase.InventoryId, SUM(purchase.Quantity) AS total_pembelian
  FROM purchases AS purchase
  GROUP BY purchase.InventoryId
),

tabela as (
  select * from barang_awal_tahun
  union all
  select * from pembelian_barang_purchase
),

inventory_after_purchase as (
  select InventoryId, sum(total_barang_awal) as inventory_gudang
  from tabela
  group by 1
),

data_penjualan as (
SELECT
    sales.InventoryId,
    SUM(SalesQuantity) AS total_penjualan
  FROM sales AS sales
  GROUP BY sales.InventoryId
), 
barang_diakhir_tahun AS (
  SELECT
    end_inv.InventoryId,
    SUM(end_inv.onHand) AS total_barang_akhir
  FROM ending_inventory AS end_inv
  GROUP BY end_inv.InventoryId
),

barang_sisa as (
  select z.InventoryId, z.inventory_gudang, COALESCE(c.total_penjualan,0) as total_penjualan, (z.inventory_gudang-COALESCE(c.total_penjualan,0)) as sisa_stok
  from inventory_after_purchase as z
  left join data_penjualan as c on z.InventoryId = c.InventoryId
),

comparation as ( 
  select r.InventoryId,COALESCE(r.sisa_stok,0), COALESCE(t.total_barang_akhir,0), (COALESCE(r.sisa_stok,0)-COALESCE(t.total_barang_akhir,0)) as difference
  from barang_sisa as r
  left join barang_diakhir_tahun as t on r.InventoryId = t.InventoryId
)

-- Perbedaan Jumlah Sisa Stok pada perhitungan dengan Catatan Akhir Inventory (17 jenis data yang berbeda) 
select*
from comparation
where comparation.difference <> 0

-- -- Terdapat sisa stok yang minus (1 jenis data)
-- select*
-- from barang_sisa
-- where barang_sisa.sisa_stok < 0

-- -- Barang yang missing, terdapat di penjualan namun tidak ada di stok (1 jenis data)
-- select *
-- from data_penjualan as d
-- left join inventory_after_purchase as i
-- on d.InventoryId=i.InventoryId
-- where i.InventoryId is null



-- -- jumlah stok sisa
-- select count(InventoryId) as jenis_barang, sum(barang_sisa.sisa_stok)
-- from barang_sisa

-- -- Jumlah stok barang (InventoryId) dan total kuantitas barang (sum quantity)
-- select count(InventoryId) as jenis_barang, sum(inventory_after_purchase.inventory_gudang)  as jumlah_barang
-- from inventory_after_purchase


