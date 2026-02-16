function Transactions()
{this.tabCurrentTransactions=new Array();this.addModel=addModel;this.removeModel=removeModel;this.getModel=getModel;this.submitModel=submitModel;this.beginTrans=beginTrans;this.commit=commit;this.rollback=rollback;this.getCurrentTransaction=getCurrentTransaction;this.setCurrentTransaction=setCurrentTransaction;this.updateRequested=updateRequested;this.insertRequested=insertRequested;this.deleteRequested=deleteRequested;this.selectRequested=selectRequested;this.existingTransactionFor=existingTransactionFor;this.existingModel=existingModel;}
function addModel(model)
{if(existingModel(model.idModel)) return false;this.tabCurrentTransactions[model.idModel]=new Transaction(this,model,null);return true;}
function removeModel(idModel)
{if(!existingModel(idModel)) return false;this.tabCurrentTransactions[idModel]=null;return true;}
function getModel(idModel)
{return this.tabCurrentTransactions[idModel].model;}
function submitModel(idModel)
{if(!existingModel(idModel)) return false;return true;}
function existingTransactionFor(idModel)
{return(this.tabCurrentTransactions[idModel]!=null);}
function existingModel(idModel)
{return existingTransactionFor(idModel);}
function getCurrentTransaction(idModel)
{return this.tabCurrentTransactions[idModel];}
function setCurrentTransaction(idModel,trans)
{this.tabCurrentTransactions[idModel]=trans;return true}
function beginTrans(idModel)
{return this.getCurrentTransaction(idModel).beginTrans();}
function commit(idModel)
{return this.getCurrentTransaction(idModel).commit();}
function rollback(idModel)
{return this.getCurrentTransaction(idModel).rollback();}
function updateRequested(idModel,path,newValue)
{if(!existingModel(idModel)) return false;return this.getCurrentTransaction(idModel).updateRequested(path,newValue);}
function insertRequested(idModel,path,at,position)
{if(!existingModel(idModel)) return false;return this.getCurrentTransaction(idModel).insertRequested(path,at,position);}
function deleteRequested(idModel,path,at)
{if(!existingModel(idModel)) return false;return this.getCurrentTransaction(idModel).deleteRequested(path,at);}
function selectRequested(idModel,path)
{if(!existingModel(idModel)) return "";return this.getCurrentTransaction(idModel).selectRequested(path);}