SELECT ROW_ID,
                       ORDER_CODE,
                       INTERFACE_NAME,
                       INTERFACE_FLAG,
                       INTERFACE_MESSAGE,
                       LAST_UPD,
                       INTERFACE_CODE,
                       MAIN_CODE
                  FROM SO_INTERFACE_LOG InterfaceLog_
                 WHERE InterfaceLog_.ORDER_CODE = '0004284779'
                   AND InterfaceLog_.INTERFACE_CODE = 'EAI_HROIS_SHIP_HGVS'
                       for update                             
