
-- total transactions per year
SELECT Year, sum(price) as total_pendapatan
from(
  select EXTRACT(YEAR from date) as Year,
  price
  from kimia_farma.kf_final_transactions
)
group by Year


-- create CTE table
WITH CTE AS(
select tf.price, tf.customer_name,(tf.price-(tf.price*tf.discount_percentage)) as nett_sales,
case
  when price <= 50000 then 0.1
  when price > 50000 and price <=100000 then 0.15
  when price > 100000 and price <= 300000 then 0.2
  when price > 300000 and price <= 500000 then 0.25
  else 0.3
end as laba,
kc.branch_name, kc.provinsi, kc.rating
from kimia_farma.kf_final_transactions tf INNER JOIN
kimia_farma.kf_kantor_cabang kc ON tf.branch_id = kc.branch_id)


-- total transaksi per provinsi
select provinsi, count(provinsi) as total_transaksi
from CTE
group by provinsi
order by total_transaksi
DESC

-- total nett sales per provinsi
select provinsi, sum(nett_sales) as total_nett_sales
from CTE
group by provinsi
order by total_nett_sales
DESC

-- total profit per provinsi
select provinsi, sum(nett_sales * laba) as total_profit
from CTE
group by provinsi
order by total_profit
DESC

-- search for high rating for branch unless for transactions
select kc.branch_id, kc.branch_name, kc.kota, tf.rating as tf_rating, kc.rating as kc_rating
from kimia_farma.kf_kantor_cabang kc join kimia_farma.kf_final_transactions tf
on kc.branch_id = tf.branch_id
order by
tf_rating ASC, kc_rating DESC

-- search penjualan produk per daerah
with CTE as(
  select kc.provinsi, tf.product_id, pd.product_category
  from kimia_farma.kf_kantor_cabang kc join
  kimia_farma.kf_final_transactions tf on kc.branch_id = tf.branch_id
  join kimia_farma.kf_product pd on tf.product_id = pd.product_id
)
select provinsi, product_category, count(product_id) as total_penjualan
from CTE
group by provinsi, product_category
order by provinsi




