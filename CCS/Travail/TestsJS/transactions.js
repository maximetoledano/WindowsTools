// gestionnaire des transactions
function Transactions()
{
	// structure de données
	this.tabCurrentTransactions = new Array();
	
	// gestion des modèles
	this.addModel=addModel;
	this.removeModel=removeModel;
	this.getModel=getModel;
	this.submitModel=submitModel;
	
	// gestion des transactions
	this.beginTrans=beginTrans;
	this.commit=commit;
	this.rollback=rollback;
	this.getCurrentTransaction=getCurrentTransaction;
	this.setCurrentTransaction=setCurrentTransaction;
	
	// manipulation des données
	this.updateRequested=updateRequested;
	this.insertRequested=insertRequested;
	this.deleteRequested=deleteRequested;
	this.selectRequested=selectRequested;
	
	// fonctions de vérification
	this.existingTransactionFor=existingTransactionFor;
	this.existingModel=existingModel;
}

// GESTION DES MODELES

// function addModel
// return boolean (succès | echec)
// pre: not(existingModel(model))
// post: existingModel(model) & getModel(model) == model
function addModel(model)
{
	if (existingModel(model.idModel)) return false;
	// le pilote est le gestionnaire de transaction lui-même
	// master est null car le pilote n'est pas une transaction et que
	// le pilote est la tête de la liste chainée des transactions
	this.tabCurrentTransactions[model.idModel] = new Transaction(this,model,null);
	return true;
}

// function removeModel
// return boolean (succès ou echec)
// pre: existingModel(idModel)
// post: not(existingModel(idModel)) && getModel(idModel) == null
function removeModel(idModel)
{
	if (!existingModel(idModel)) return false;
	this.tabCurrentTransactions[idModel] = null;
	return true;
}

// function getModel
// return Model 
// pre: existingModel(idModel)
function getModel(idModel)
{
	return this.tabCurrentTransactions[idModel].model;
}
 
// function submitModel
// return boolean ( succès | échec )
// pre: existingModel(model)
function submitModel(idModel)
{
	if (!existingModel(idModel)) return false;
	// à faire...
	return true;
}
 
// FONCTIONS DE VERIFICATION
 
// functions existingTransactionFor & existingModel
// return Boolean
function existingTransactionFor(idModel)
{
	return (this.tabCurrentTransactions[idModel] != null);
}
function existingModel(idModel)
{
	return existingTransactionFor(idModel);
}

// GESTION DES TRANSACTIONS

// function getCurrentTransaction
// return Transaction
// pre: existingModel(idModel)
// il y a toujours une transaction courante pour chaque modèle
function getCurrentTransaction(idModel)
{
	return this.tabCurrentTransactions[idModel];
}	

// function setCurrentTransaction
// return boolean
// pre: existingModel(idModel)
// appel interne venant de la liste chainée des transactions
function setCurrentTransaction(idModel,trans)
{
	this.tabCurrentTransactions[idModel] = trans;
	return true
}

// function beginTrans
// return boolean
// pre: existingModel(idModel)
function beginTrans(idModel)
{
	return this.getCurrentTransaction(idModel).beginTrans();
}

// function commit
// return boolean
// pre: existingModel(idModel)
function commit(idModel)
{
	return this.getCurrentTransaction(idModel).commit();
}

// function rollback
// return boolean
// pre: existingModel(idModel)
function rollback(idModel)
{
	return this.getCurrentTransaction(idModel).rollback();
}

// MANIPULATION DES DONNEES

// function updateRequested(path, newValue)
// return boolean
// pre: existingModel(idModel)  && celles de model.updateRequested
function updateRequested(idModel, path, newValue)
{
	if (!existingModel(idModel)) return false;
	return this.getCurrentTransaction(idModel).updateRequested(path, newValue);
}

function insertRequested(idModel,path, at, position)
{
	if (!existingModel(idModel)) return false;
	return this.getCurrentTransaction(idModel).insertRequested(path, at, position);
}

function deleteRequested(idModel,path, at)
{
	if (!existingModel(idModel)) return false;
	return this.getCurrentTransaction(idModel).deleteRequested(path, at);
}

// function selectRequested
// return ? string ?
// pre: existingModel(idModel) && existingPath(path)
function selectRequested(idModel,path)
{
	if (!existingModel(idModel)) return "";
	return this.getCurrentTransaction(idModel).selectRequested(path);
}		