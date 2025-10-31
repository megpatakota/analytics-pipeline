
      
        
            delete from "primary_app_db"."public_analytics"."fact_sales"
            using "fact_sales__dbt_tmp144912722937"
            where (
                
                    "fact_sales__dbt_tmp144912722937".order_key = "primary_app_db"."public_analytics"."fact_sales".order_key
                    and 
                
                    "fact_sales__dbt_tmp144912722937".product_key = "primary_app_db"."public_analytics"."fact_sales".product_key
                    
                
                
            );
        
    

    insert into "primary_app_db"."public_analytics"."fact_sales" ("order_key", "customer_key", "product_key", "sales_timestamp", "sales_date", "units_sold", "unit_price_at_sale", "gross_revenue_amount", "product_sku", "product_category_name", "order_status", "source_system")
    (
        select "order_key", "customer_key", "product_key", "sales_timestamp", "sales_date", "units_sold", "unit_price_at_sale", "gross_revenue_amount", "product_sku", "product_category_name", "order_status", "source_system"
        from "fact_sales__dbt_tmp144912722937"
    )
  