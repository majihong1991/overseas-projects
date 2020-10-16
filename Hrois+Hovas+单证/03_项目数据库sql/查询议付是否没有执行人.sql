SELECT AU.PROC_INST_ID_,
       AU.PROC_DEF_ID_,
       AU.NAME_,
       WF.BUSINFORM_ID
FROM   ACT_RU_TASK AU
LEFT   JOIN WF_PROCINSTANCE WF
ON     AU.PROC_INST_ID_ = WF.PROCESSINSTANCE_ID
WHERE  AU.TASK_DEF_KEY_ = 'conferPayInvoice'
AND    AU.ASSIGNEE_ IS NULL;
