saleV2 = {}
--------------------------------PARAMETERS--------------------------------
PING = 50 --Temps d'attente maximal pour la réception du package, Valeur recommander PING + 40 (generalement le bot envoie une requete et en recois le resultats a une valeur égale à leurs ~ping).
STEP = 10 --L'intervalle de vérification de la réception d'un package. (en ms, valeur supérieur strictement à 0)
REQUEST_DELAY = 100 -- en ms (le temps d'attente entre le spam des requetes pour modification du prix par exemple)
DEBUG = true --Afficher les details sur la console
--------------------------------------------------------------------------
--------------------------------DONT TOUCH--------------------------------
--------------------------------------------------------------------------
SALE = {}
PRICE = {gid = 0, avg = 0 , marketPrice = {}}
KILL = false

--Package itemsOnSale
function _ExchangeStartedBidSellerMessage(message)
    local struct = {itemsOnSale = -1, items = {}}
    struct.itemsOnSale = #message.objecttsInfos
    if DEBUG then 
        global:printColor("#00FF00","-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
        global:printError("Nombre d'item en vente -> "..struct.itemsOnSale)
    end
    for i = 1 , struct.itemsOnSale do
        local data = {index = i, gid = message.objecttsInfos[i].objecttGID, uid = message.objecttsInfos[i].objecttUID, quantity = message.objecttsInfos[i].quantity, price = message.objecttsInfos[i].objecttPrice}
        if DEBUG then global:printSuccess("["..inventory:itemNameId(data.gid).."] | Index -> "..data.index.." | GID -> "..data.gid.." | UID -> "..data.uid.." | Quantity -> "..data.quantity.." | Price -> "..data.price) end
        table.insert(struct.items,data)
    end
    if DEBUG then global:printColor("#00FF00","-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------") end
    SALE = struct
end

--Package itemsOnMarket
function _ExchangeBidPriceForSellerMessage(message)
    PRICE.avg = message.averagePrice
    PRICE.marketPrice = message.minimalPrices
    PRICE.gid = message.genericId
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------METHODES-----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Méthode permettant de récupérer le prix d'un objet en Hôtel de Vente.
function saleV2:getPriceItem(gid,quantity)
    if not KILL then
        developer:registerMessage("ExchangeBidPriceForSellerMessage", _ExchangeBidPriceForSellerMessage)
        local ExchangeBidHousePriceMessage = developer:createMessage("ExchangeBidHousePriceMessage")
        ExchangeBidHousePriceMessage.objectGID = gid
        developer:sendMessage(ExchangeBidHousePriceMessage)
        developer:suspendScriptUntil("ExchangeBidPriceForSellerMessage", PING*2, false, "-1", STEP)
        developer:unRegisterMessage("ExchangeBidPriceForSellerMessage")
        if DEBUG then 
            global:printColor("#00FF00","-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
            global:printColor("#e1ff34",inventory:itemNameId(gid).." x 1 = "..PRICE.marketPrice[1])
            global:printColor("#e1ff34",inventory:itemNameId(gid).." x 10 = "..PRICE.marketPrice[2])
            global:printColor("#e1ff34",inventory:itemNameId(gid).." x 100 = "..PRICE.marketPrice[3])
            global:printColor("#00FF00","-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
        end
        if quantity == 100 then
            return PRICE.marketPrice[3]
        elseif quantity == 10 then
            return PRICE.marketPrice[2]
        elseif quantity == 1 then
            return PRICE.marketPrice[1]
        else
            global:printError("Erreur à la réccuperation du lot, "..quantity.." ne correspond à aucun lot")
            global:finishScript()
        end
    end
end

--Méthode permettant de récupérer le prix moyen d'un objet.
function saleV2:getAVGPrice(gid,quantity)
    if not KILL then
        developer:registerMessage("ExchangeBidPriceForSellerMessage", _ExchangeBidPriceForSellerMessage)
        local ExchangeBidHousePriceMessage = developer:createMessage("ExchangeBidHousePriceMessage")
        ExchangeBidHousePriceMessage.objectGID = gid
        developer:sendMessage(ExchangeBidHousePriceMessage)
        developer:suspendScriptUntil("ExchangeBidPriceForSellerMessage", PING*2, false, "-1", STEP)
        developer:unRegisterMessage("ExchangeBidPriceForSellerMessage")
        local result = PRICE.avg * quantity
        if DEBUG then
            global:printColor("#00FF00","-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
            global:printColor("#e1ff34",inventory:itemNameId(gid).." Quantity x 1 = "..PRICE.marketPrice[1].." | AVG x 1 = "..tostring(PRICE.avg*1))
            global:printColor("#e1ff34",inventory:itemNameId(gid).." Quantity x 10 = "..PRICE.marketPrice[2].." | AVG x 10 = "..tostring(PRICE.avg*10))
            global:printColor("#e1ff34",inventory:itemNameId(gid).." Quantity x 100 = "..PRICE.marketPrice[3].." | AVG x 100 = "..tostring(PRICE.avg*100))
            global:printColor("#00FF00","-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
        end
        return result
    end
end
--Méthode permettant de modifier le prix d'un objet depuis l'Hôtel de Vente.
function saleV2:editPrice(guid,price,quantity)
    if not KILL then
        local ExchangeObjectModifyPricedMessage = developer:createMessage("ExchangeObjectModifyPricedMessage")
        ExchangeObjectModifyPricedMessage.price = price
        ExchangeObjectModifyPricedMessage.objecttUID = guid
        ExchangeObjectModifyPricedMessage.quantity = quantity
        developer:sendMessage(ExchangeObjectModifyPricedMessage)
    end
end
--Méthode permettant de modifier les prix des objets ayant le même identifiant et la même quantité depuis l'Hôtel de Vente.
function saleV2:editPriceByGID(gid,price,quantity)
    if not KILL then
        local itemsToEdit = {}
        for _, item in pairs(SALE.items) do
            if item.gid == gid and item.quantity == quantity then
                table.insert(itemsToEdit,item)
            end
        end
        for _, toEdit in ipairs(itemsToEdit) do
            saleV2:editPrice(toEdit.uid,price,quantity)
            global:delay(REQUEST_DELAY)
        end
    end
end
--Méthode retournant le nombre d'objets mis en vente par le personnage dans l'Hôtel de Vente.
function saleV2:itemsOnSale()
    return SALE.itemsOnSale
end
--Méthode permettant de récupérer l'identifiant de l'objet.
function saleV2:getItemGID(index)
    return SALE.items[index].gid
end
--Méthode permettant de récupérer le prix d'un de vos objets depuis l'Hôtel de Vente.
function saleV2:getItemPrice(index)
    return SALE.items[index].price
end
--Méthode retournant la quantité de l'objet en vente.
function saleV2:getItemQuantity(index)
    return SALE.items[index].quantity
end
--Méthode permettant de récupérer l'identifiant privé de l'objet ciblé.
function saleV2:getItemGUID(index)
    return SALE.items[index].uid
end
--Méthode permettant d'actualiser le prix de tous les objets déjà mis en vente par le personnage dans l'Hôtel de Vente, de telle manière à ce que vos prix soient les plus bas, une sécurité sur le prix selon le prix moyen a été ajouter.
--Baisser le prix de : Nombre de kamas à retrancher par rapport au prix le plus bas.
--TAUX_TOLERANCE : Tolerance au prix moyen en HDV Valeur entre [0.0 : ??.??](exemple 0.5 segnifie que si le prix en HDV été inférieur strictement à 50% de la valeur éstimé : le prix de notre objet en vente ne sera pas modifier)
function saleV2:updateAllItems(BAISSER_LE_PRIX_DE,TAUX_TOLERANCE)
    if not KILL then
        global:leaveDialog()
        local startClock = os.clock()
        if DEBUG then 
            global:printSuccess("Debut de modification de prix ...")
            global:printError("[ATTENTION] Cette fonction n'est pas valable pour l'HDV des archimonstre")
        end
        developer:registerMessage("ExchangeStartedBidSellerMessage", _ExchangeStartedBidSellerMessage)
        npc:npc(-1, 5)
        developer:suspendScriptUntil("ExchangeStartedBidSellerMessage", PING*2, false, "-1", STEP)
        developer:unRegisterMessage("ExchangeStartedBidSellerMessage")
        local numberOfitemsOnSale =  saleV2:itemsOnSale()
        local marketSnapShot = {}
        if numberOfitemsOnSale > 0 then
            for index = 1 , numberOfitemsOnSale do
                global:printSuccess("index "..index)
                local data = {gid = saleV2:getItemGID(index) , price = saleV2:getItemPrice(index), lot = saleV2:getLot(saleV2:getItemQuantity(index)), quantity = saleV2:getItemQuantity(index) , marketPrice = -1, averagePrice = -1 }
                data.marketPrice = saleV2:getPriceItem(data.gid, data.quantity)
                data.averagePrice = saleV2:getAVGPrice(data.gid,data.quantity)
                if not saleV2:isElementExist(data,marketSnapShot) and data.averagePrice > 0 then
                    table.insert(marketSnapShot,data)
                elseif data.averagePrice == 0 then
                    if DEBUG then global:printError(inventory:itemNameId(data.gid).." ne possède pas de valeur de prix moyen, par sécurité on ne modifiera pas son prix") end
                end
            end
            for _, itemOnMarket in pairs(marketSnapShot) do
                if itemOnMarket.marketPrice < itemOnMarket.price and itemOnMarket.marketPrice > math.floor(itemOnMarket.averagePrice*TAUX_TOLERANCE)  then
                    saleV2:editPriceByGID(itemOnMarket.gid, itemOnMarket.marketPrice - BAISSER_LE_PRIX_DE, itemOnMarket.quantity)
                    if DEBUG then global:printSuccess("Le prix a bien été modifier pour "..inventory:itemNameId(itemOnMarket.gid).." lot x"..itemOnMarket.quantity) end
                end
            end
        else
            global:printError("il n'y a pas d'objet mis en vente actuelement dans cet HDV")
        end
        local endTime = os.clock()
        local timer = endTime - startClock
        if DEBUG then global:printSuccess("Function Terminer, Durée d'execution : "..tostring(timer).." seconde(s)") end
        global:leaveDialog()
    end
end

-------------------------------UTILITIES----------------------------------
function saleV2:isElementExist(elem,list)
    for _, elt in ipairs(list) do
        if elt == elem then
            return true
        end
    end
    return false
end

function saleV2:getLot(quantity)
    if quantity == 100 then
        return 3
    elseif quantity == 10 then
        return 2
    elseif quantity == 1 then
        return 1
    else
        global:printError("Erreur à la réccuperation du lot, "..quantity.." ne correspond à aucun lot")
    end
end
if PING < 40 or STEP <= 0 then global:printError("Are you crazy ?!") global:printError("LE STEP DOIT ETRE SUPERIEUR STRICTEMENT À 0") global:printError("LE PING NE DOIT PAS ETRE INFERIEUR À 40, LA VALEUR MINIMAL RECOMMENDER EST VOTRE PING +40") KILL = true end
-------------------------------------------------------------------------
return saleV2