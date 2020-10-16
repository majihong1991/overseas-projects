SELECT ACT_CONF_PAY_ITEM_CODE,
                       ACT_CONF_PAY_CODE,
                       ORDER_NUM,
                       ORDER_LINECODE,
                       PAYMENT_METHOD,
                       PAY_CODE,
                       PAYMENT_PERIOD,
                       AMOUNT,
                       CURRENCY,
                       ACTIVE_FLAG,
                       ui.name as CREATED_BY,
                       CREATED,
                       LAST_UPD_BY,
                       LAST_UPD,
                       MODIFICATION_NUM
                  FROM ACT_CONF_PAY_ORDER_ITEM ConfPayOrderItem_
                  left join user_info ui
                    on ConfPayOrderItem_.created_by = ui.emp_code
                 WHERE ConfPayOrderItem_.ORDER_NUM = '0004028936'
        
