sgs.ai_skill_invoke.chongzhen = function(self, data)
	local target = self.player:getTag("ChongZhenTarget"):toPlayer()
	if self:isFriend(target) then
		return target:hasSkill("kongcheng") and target:getHandcardNum() == 1
	else
		return not (target:hasSkill("kongcheng") and target:getHandcardNum() == 1 and target:getEquips():isEmpty())
	end
end

--AI for BGM Diaochan
--code by clarkcyt and William915

local lihun_skill={}
lihun_skill.name="lihun"
table.insert(sgs.ai_skills,lihun_skill)
lihun_skill.getTurnUseCard=function(self)
	if self.player:hasUsed("LihunCard") or self.player:isNude() then return end
	local card_id
	if (self:isEquip("SilverLion") and self.player:isWounded()) or self:evaluateArmor() < -5 then
		return sgs.Card_Parse("@LihunCard=" .. self.player:getArmor():getId())
	elseif self.player:getHandcardNum() > self.player:getHp() then
		local cards = self.player:getHandcards()
		cards=sgs.QList2Table(cards)

		for _, acard in ipairs(cards) do
			if (acard:getTypeId() ~= sgs.Card_Trick or acard:inherits("AmazingGrace"))
				and not acard:inherits("Peach") and not acard:inherits("Shit")
				and not (acard:inherits("Slash") and self:getCardsNum("Slash") == 1) then
				card_id = acard:getEffectiveId()
				break
			end
		end
	elseif not self.player:getEquips():isEmpty() then
		local player=self.player
		if player:getWeapon() then card_id=player:getWeapon():getId()
		elseif player:getOffensiveHorse() then card_id=player:getOffensiveHorse():getId()
		elseif player:getDefensiveHorse() then card_id=player:getDefensiveHorse():getId()
		elseif player:getArmor() and player:getHandcardNum()<=1 then card_id=player:getArmor():getId()
		end
	end
	if not card_id then
		cards=sgs.QList2Table(self.player:getHandcards())
		for _, acard in ipairs(cards) do
			if (acard:getTypeId() ~= sgs.Card_Trick or acard:inherits("AmazingGrace"))
				and not acard:inherits("Peach") and not acard:inherits("Shit") then
				card_id = acard:getEffectiveId()
				break
			end
		end
	end
	if not card_id then
		return nil
	else
		return sgs.Card_Parse("@LihunCard=" .. card_id)
	end
end

sgs.ai_skill_use_func.LihunCard = function(card,use,self)
	local cards=self.player:getHandcards()
	cards=sgs.QList2Table(cards)

	if not self.player:hasUsed("LihunCard") then
		self:sort(self.enemies, "hp")
		local target
		for _, enemy in ipairs(self.enemies) do
			if enemy:getGeneral():isMale() and not enemy:hasSkill("kongcheng") then
			    if (enemy:hasSkill("lianying") and self:damageMinusHp(self, enemy, 1) > 0) or
				   (enemy:getHp() < 3 and self:damageMinusHp(self, enemy, 0) > 0  and enemy:getHandcardNum() > 0) or
				   (enemy:getHandcardNum() >= enemy:getHp() -1 and enemy:getHp() > 2 and self:damageMinusHp(self, enemy, 0) + enemy:getHp() > 1) or
				   (enemy:getHandcardNum() - enemy:getHp() > 4) then
					target = enemy
					break
				end
			end
		end

		if target then
			use.card = card
			if use.to then
--				self.room:setPlayerFlag(target, "lihun_target")
				use.to:append(target)
			end
		end
	end
end

sgs.ai_skill_cardchosen.lihun = function(self)
	if self:isEquip("SilverLion") and self.player:isWounded() or self:evaluateArmor() < -5 then
		return self.player:getArmor()
	end
	local shit = self:getCard("Shit")
	if shit then return shit end
	local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByKeepValue(cards)
	return cards[1]
end

sgs.ai_use_value.LihunCard = 8.5
sgs.ai_use_priority.LihunCard = 6

--AI for BGM Caoren

function sgs.ai_skill_invoke.kuiwei(self, data)
    local weapon = 0
    if not self.player:faceUp() then return true end
	for _, friend in ipairs(self.friends) do
		if self:hasSkills("fangzhu|jilve", friend) then return true end
	end
	for _, aplayer in sgs.qlist(self.room:getAlivePlayers()) do
	    if aplayer:getWeapon() then weapon = weapon + 1 end
	end
	if weapon >1 then return true end
	return self:isWeak()
end

sgs.ai_view_as.yanzheng = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if card_place == sgs.Player_Equip then
	    return ("nullification:yanzheng[%s:%s]=%d"):format(suit, number, card_id)
	end
end

-- AI for bgm_pangong

sgs.ai_skill_invoke.manjuan = true
sgs.ai_skill_invoke.zuixiang = true

sgs.ai_skill_askforag.manjuan = function(self, card_ids)
	local cards = {}
	for _, card_id in ipairs(card_ids) do
		table.insert(cards, sgs.Sanguosha:getCard(card_id))
	end
	for _, card in ipairs(cards) do
		if card:inherits("ExNihilo") then return card:getEffectiveId() end
	end
	for _, card in ipairs(cards) do
		if card:inherits("Snatch") then
			self:sort(self.enemies,"defense")
			if sgs.getDefense(self.enemies[1]) >= 8 then self:sort(self.enemies, "threat") end
			local enemies = self:exclude(self.enemies, card)
			for _,enemy in ipairs(enemies) do
				if self:hasTrickEffective(card, enemy) then
					return card:getEffectiveId()
				end
			end
		end
	end
	for _, card in ipairs(cards) do
		if card:inherits("Peach") and self.player:isWounded() and self:getCardsNum("Peach") < self.player:getLostHp() then return card:getEffectiveId() end
	end
	for _, card in ipairs(cards) do
		if card:inherits("AOE") and self:getAoeValue(card) > 0 then return card:getEffectiveId() end
	end
	self:sortByCardNeed(cards)
	return cards[#cards]:getEffectiveId()
end

local dahe_skill={}
dahe_skill.name="dahe"
table.insert(sgs.ai_skills,dahe_skill)
dahe_skill.getTurnUseCard=function(self)
	if not self.player:hasUsed("DaheCard") and not self.player:isKongcheng() then return sgs.Card_Parse("@DaheCard=.") end
end

sgs.ai_skill_use_func.DaheCard=function(card,use,self)
	self:sort(self.enemies, "handcard")
	local max_card = self:getMaxCard(self.player)
	local max_point = max_card:getNumber()
	local slashcount = self:getCardsNum("Slash")
	if max_card:inherits("Slash") then slashcount = slashcount - 1 end
	if self.player:hasSkill("kongcheng") and self.player:getHandcardNum()==1 then
		for _, enemy in ipairs(self.enemies) do
			if not enemy:isKongcheng() then
				use.card = sgs.Card_Parse("@DaheCard=" .. max_card:getId())
				if use.to then use.to:append(enemy) end
				return
			end
		end
	end
	if slashcount > 0 then
		local slash = self:getCard("Slash")
		assert(slash)
		local dummy_use = {isDummy = true}
		self:useBasicCard(slash, dummy_use)
		for _, enemy in ipairs(self.enemies) do
			if not (enemy:hasSkill("kongcheng") and enemy:getHandcardNum() == 1 and enemy:getHp() > self.player:getHp())
				and not enemy:isKongcheng() and self.player:canSlash(enemy, true) then
				local enemy_max_card = self:getMaxCard(enemy)
				if (enemy_max_card and max_point > enemy_max_card:getNumber())
					or (enemy_max_card and max_point > enemy_max_card:getNumber() and max_point > 10)
					or (not enemy_max_card and max_point > 10) then
					use.card = sgs.Card_Parse("@DaheCard=" .. max_card:getId())
					if use.to then use.to:append(enemy) end
					return
				end
			end
		end
	end
end

function sgs.ai_skill_pindian.dahe(minusecard, self, requestor)
	if self:isFriend(requestor) then return minusecard end
	return self:getMaxCard(self.player):getId()
end

sgs.ai_skill_choice.dahe = function(self, choices)
	return "yes"
end

sgs.ai_skill_playerchosen.dahe = function(self, targets)
	targets = sgs.QList2Table(targets)
	self:sort(targets, "defense")
	for _, target in ipairs(targets) do
		if target:hasSkill("kongcheng") and target:isKongcheng()
			and target:hasFlag("dahe") then
			return target
		end
	end
	for _, target in ipairs(targets) do
		if self:isFriend(target) then return target end
	end
end

sgs.ai_skill_cardask["@dahe-jink"] = function(self, data, pattern, target)
	if self.player:hasFlag("dahe") then
		for _, card in ipairs(self:getCards("Jink")) do
			if card:getSuit() == sgs.Card_Heart then
				return card:getId()
			end
		end
			return "."
	end
end

sgs.ai_cardneed.dahe = sgs.ai_cardneed.bignumber

sgs.ai_card_intention.DaheCard = 60

sgs.dynamic_value.control_card.DaheCard = true

sgs.ai_use_value.DaheCard = 8.5
sgs.ai_use_priority.DaheCard = 8

local tanhu_skill={}
tanhu_skill.name="tanhu"
table.insert(sgs.ai_skills,tanhu_skill)
tanhu_skill.getTurnUseCard=function(self)
	if not self.player:hasUsed("TanhuCard") and not self.player:isKongcheng() then
		local max_card = self:getMaxCard()
		return sgs.Card_Parse("@TanhuCard=" .. max_card:getEffectiveId())
	end
end

sgs.ai_skill_use_func.TanhuCard = function(card, use, self)
	local max_card = self:getMaxCard()
	local max_point = max_card:getNumber()
	local ptarget = self:getPriorTarget()
	local slashcount = self:getCardsNum("Slash")
	if max_card:inherits("Slash") then slashcount = slashcount - 1 end
	if not ptarget:isKongcheng() and slashcount > 0 and self.player:canSlash(ptarget, true)
	and not ptarget:hasSkill("kongcheng") and ptarget:getHandcardNum() == 1 then
		local card_id = max_card:getEffectiveId()
		local card_str = "@TanhuCard=" .. card_id
		if use.to then
			use.to:append(ptarget)
		end
		use.card = sgs.Card_Parse(card_str)
		return
	end
	self:sort(self.enemies, "defense")

	for _, enemy in ipairs(self.enemies) do
		if self:getCardsNum("Snatch") > 0 and not enemy:isKongcheng() then
			local enemy_max_card = self:getMaxCard(enemy)
			if (enemy_max_card and max_point > enemy_max_card:getNumber())
				or (enemy_max_card and max_point > enemy_max_card:getNumber() and max_point > 10)
				or (not enemy_max_card and max_point > 10) and
				(self:getDangerousCard(enemy) or self:getValuableCard(enemy)) then
					local card_id = max_card:getEffectiveId()
					local card_str = "@TanhuCard=" .. card_id
					if use.to then
						use.to:append(enemy)
					end
					use.card = sgs.Card_Parse(card_str)
					return
			end
		end
	end
	local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards, true)
	if self:getUseValue(cards[1]) >= 6 or self:getKeepValue(cards[1]) >= 6 then return end
	if self:getOverflow() > 0 then
		if not ptarget:isKongcheng() then
			local card_id = max_card:getEffectiveId()
			local card_str = "@TanhuCard=" .. card_id
			if use.to then
				use.to:append(ptarget)
			end
			use.card = sgs.Card_Parse(card_str)
			return
		end
		for _, enemy in ipairs(self.enemies) do
			if not (enemy:hasSkill("kongcheng") and enemy:getHandcardNum() == 1) and not enemy:isKongcheng() and not enemy:hasSkill("tuntian") then
				use.card = sgs.Card_Parse("@TanhuCard=" .. cards[1]:getId())
				if use.to then use.to:append(enemy) end
				return
			end
		end
	end
end

sgs.ai_cardneed.tanhuhu = sgs.ai_cardneed.bignumber
sgs.ai_card_intention.TanhuCard = 30
sgs.dynamic_value.control_card.TanhuCard = true
sgs.ai_use_priority.TanhuCard = 8

sgs.ai_skill_invoke.mouduan = function(self, data)
	return self:isEquip("Crossbow") or self:getCardsNum("Crossbow") > 0
end

sgs.ai_skill_invoke.zhaolie = function(self, data)
	local enemynum = 0
	for _, enemy in ipairs(self.enemies) do
		if self.player:distanceTo(enemy) <= self.player:getAttackRange() then
			enemynum = enemynum + 1
		end
	end
	return enemynum > 0
end

sgs.ai_skill_playerchosen.zhaolie = function(self, targets)
	targets = sgs.QList2Table(targets)
	self:sort(targets, "hp")
	for _, target in ipairs(targets) do
		if self:isEnemy(target) then
			return target
		end
	end
	return targets[1]
end

sgs.ai_skill_choice.zhaolie = function(self, choices, data)
	local nobasic = data:toInt()
	if nobasic == 0 then
		return "damage"
	end
	if nobasic < 2 and self.player:getHp() > 1 then
		return "damage"
	else
		return "throw"
	end
end

sgs.ai_skill_discard.zhaolie = function(self, discard_num, min_num, optional, include_equip)
	local to_discard = {}
	local cards = sgs.QList2Table(self.player:getCards("he"))
	local index = 0

	self:sortByKeepValue(cards)
	cards = sgs.reverse(cards)

	for i = #cards, 1, -1 do
		local card = cards[i]
		if not self.player:isJilei(card) then
			table.insert(to_discard, card:getEffectiveId())
			table.remove(cards, i)
			index = index + 1
			if index == discard_num then break end
		end
	end
	if #to_discard ~= discard_num then return {}
	else
		return to_discard
	end
end

sgs.ai_skill_use["@@shichou"] = function(self, prompt)
	local first = self.room:getTag("FirstRound"):toBool()
	if not first then return "." end
	
	local cards = self.player:getCards("he")
	cards=sgs.QList2Table(cards)
	local first, second
	self:sortByUseValue(cards,true)
	for _, card in ipairs(cards) do
		if not first then
			first = card:getEffectiveId()
		else second = card:getEffectiveId()
		end
		if second then break end
	end
	if not second or not first then return "." end
	
    local target = self.room:findPlayerBySkillName("wuhun")
	local players = self.room:getOtherPlayers(self.player)
	if target and target:getKingdom() == "shu" then
		return "@ShichouCard:".. first .. "+".. second .. ":->" .. target:objectName()
	end
	for _, player in sgs.qlist(players) do
		if player:getKingdom() == "shu" then
			if self:isEnemy(player) then
				return "@ShichouCard:".. first .. "+".. second .. ":->" .. player:objectName()
			end
		end
	end
	return "."
end

sgs.ai_use_priority.YanxiaoCard = 3.9
sgs.ai_card_intention.YanxiaoCard = -80

local yanxiao_skill={}
yanxiao_skill.name="yanxiao"
table.insert(sgs.ai_skills,yanxiao_skill)
yanxiao_skill.getTurnUseCard=function(self)
	return sgs.Card_Parse("@YanxiaoCard=.")
end

sgs.ai_skill_use_func.YanxiaoCard=function(card,use,self)
	local cards = self.player:getCards("he")
	cards=sgs.QList2Table(cards)
	self:sortByUseValue(cards,true)

	local target
	for _, friend in ipairs(self.friends_noself) do
		local judges = friend:getJudgingArea()
		if not judges:isEmpty() and friend:property("yanxiao"):toInt() < 1 then
			for _, card in ipairs(cards) do
				if card:getSuit() == sgs.Card_Diamond and self.player:getHandcardNum() > 1 then
					use.card = sgs.Card_Parse("@YanxiaoCard=" .. card:getEffectiveId())
					target = friend
					break
				end
			end
		end
		if target then break end
	end
	if not target and self.player:property("yanxiao"):toInt() < 1 then
		for _, card in ipairs(cards) do
			if card:getSuit() == sgs.Card_Diamond  then
				use.card = sgs.Card_Parse("@YanxiaoCard=" .. card:getEffectiveId())
				target = self.player
				break
			end
		end
	end
	if target then
		if use.to then
			use.to:append(target)
		end
	end
end

sgs.ai_skill_invoke.anxian = function(self, data)
	local damage = data:toDamage()
	local target = damage.to
	if self:isFriend(target) and not self:hasSkills(sgs.masochism_skill,target) then return true end
	if self:isEnemy(target) and self:hasSkills(sgs.masochism_skill,target) then return true end
	if damage.card:hasFlag("drank") then return false end
	return false
end

sgs.ai_skill_cardask["@anxian-discard"] = function(self, data)
	if self:getCardsNum("Jink") > 0 or self.player:isKongcheng() then return "." end
	local cards = self.player:getHandcards()
	cards=sgs.QList2Table(cards)
	self:sortByKeepValue(cards)

	return "$" .. cards[1]:getEffectiveId()
end

local yinling_skill={}
yinling_skill.name="yinling"
table.insert(sgs.ai_skills,yinling_skill)
yinling_skill.getTurnUseCard=function(self,inclusive)
    local cards = self.player:getCards("he")
    cards=sgs.QList2Table(cards)

    local black_card

    self:sortByUseValue(cards,true)

    local has_weapon=false

    for _,card in ipairs(cards) do
        if card:isKindOf("Weapon") and card:isBlack() then has_weapon=true end
    end

    for _,card in ipairs(cards)  do
        if card:isBlack()  and ((self:getUseValue(card)<sgs.ai_use_value.YinlingCard) or inclusive or self:getOverflow()>0) then
            local shouldUse=true

            if card:isKindOf("Armor") then
                if not self.player:getArmor() then shouldUse=false
                elseif self:hasEquip(card) and not (card:isKindOf("SilverLion") and self.player:isWounded()) then shouldUse=false
                end
            end

            if card:isKindOf("Weapon") then
                if not self.player:getWeapon() then shouldUse=false
                elseif self:hasEquip(card) and not has_weapon then shouldUse=false
                end
            end

            if card:isKindOf("Slash") then
                local dummy_use = {isDummy = true}
                if self:getCardsNum("Slash") == 1 then
                    self:useBasicCard(card, dummy_use)
                    if dummy_use.card then shouldUse = false end
                end
            end

            if self:getUseValue(card) > sgs.ai_use_value.YinlingCard and card:isKindOf("TrickCard") then
                local dummy_use = {isDummy = true}
                self:useTrickCard(card, dummy_use)
                if dummy_use.card then shouldUse = false end
            end

            if shouldUse then
                black_card = card
                break
            end

        end
    end

    if black_card then
        local card_id = black_card:getEffectiveId()
        local card_str = ("@YinlingCard="..card_id)
        local yinling = sgs.Card_Parse(card_str)

        assert(yinling)

        return yinling
    end
end

sgs.ai_skill_use_func.YinlingCard=function(card,use,self)
	if self.player:getPile("brocade"):length() >= 4 then return end
	local players = self.room:getOtherPlayers(self.player)
	players = self:exclude(players, card)

	self:sort(self.enemies,"defense")
	if #self.enemies > 0 and sgs.getDefense(self.enemies[1]) >= 8 then self:sort(self.enemies, "threat") end
	local enemies = self:exclude(self.enemies, card)
	self:sort(self.friends_noself,"defense")
	local friends = self:exclude(self.friends_noself, card)
	local hasLion, target
	for _, enemy in ipairs(enemies) do
		if not enemy:isNude() and self:hasTrickEffective(card, enemy) then
			if self:getDangerousCard(enemy) then
				use.card = card
				if use.to then
					sgs.ai_skill_cardchosen.yinling = self:getDangerousCard(enemy)
					use.to:append(enemy)
					self:speak("hostile", self.player:isFemale())
				end
				return
			end
		end
	end

	for _, friend in ipairs(friends) do
		if self:isEquip("SilverLion", friend) and self:hasTrickEffective(card, friend) and
		friend:isWounded() and not self:hasSkills("longhun|duanliang|qixi|guidao|lijian|jujian",friend) then
			hasLion = true
			target = friend
		end
	end

	for _, enemy in ipairs(enemies) do
		if not enemy:isNude() and self:hasTrickEffective(card, enemy) then
			if self:getValuableCard(enemy) then
				use.card = card
				if use.to then
					sgs.ai_skill_cardchosen.yinling = self:getValuableCard(enemy)
					use.to:append(enemy)
					self:speak("hostile", self.player:isFemale())
				end
				return
			end
		end
	end

	if hasLion then
		use.card = card
		if use.to then
			sgs.ai_skill_cardchosen.yinling = target:getArmor():getEffectiveId()
			use.to:append(target)
		end
		return
	end

	for _, enemy in ipairs(enemies) do
		if not enemy:isKongcheng() and (enemy:getHandcardNum() > enemy:getHp() - 2 or (enemy:getHandcardNum() == 1 and not self:needKongcheng(enemy))) then
			use.card = card
			if use.to then
				sgs.ai_skill_cardchosen.yinling = enemy:getRandomHandCardId()
				use.to:append(enemy)
			end
			return
		end
	end

	return
end

sgs.ai_use_value.YinlingCard = sgs.ai_use_value.Dismantlement + 1
sgs.ai_use_priority.YinlingCard = sgs.ai_use_priority.Dismantlement + 1
sgs.ai_card_intention.YinlingCard = sgs.ai_card_intention.Dismantlement

sgs.ai_skill_invoke.junwei = function(self, data)
	return #self.enemies > 0
end

sgs.ai_skill_playerchosen.junwei = function(self, targets)
	local tos = {}
	for _, target in sgs.qlist(targets) do
		if not self:isFriend(target) and not (self:isEquip("SilverLion", target) and target:getCards("e"):length() == 1)then
			table.insert(tos, target)
		end
	end

	if #tos > 0 then
		self:sort(tos, "defense")
		return tos[1]
	end
end

sgs.ai_skill_playerchosen.junweigive = function(self, targets)
	local tos = {}
	for _, target in sgs.qlist(targets) do
		if self:isFriend(target) and not target:hasSkill("manjuan") and not (target:hasSkill("kongcheng") and target:isKongcheng()) then
			table.insert(tos, target)
		end
	end

	if #tos > 0 then
		self:sort(tos, "defense")
		return tos[1]
	end
end

sgs.ai_skill_cardchosen.junwei = function(self, who, flags)
	if flags == "e" then
		if who:getArmor() then return who:getArmor() end
		if who:getDefensiveHorse() then return who:getDefensiveHorse() end
		if who:getOffensiveHorse() then return who:getOffensiveHorse() end
		if who:getWeapon() then return who:getWeapon() end
	end
end

sgs.ai_skill_cardask["@junwei-show"] = function(self, data)
	local ganning = data:toPlayer()
	local cards = self.player:getHandcards()
	cards=sgs.QList2Table(cards)
	for _,card in ipairs(cards) do
		if card:isKindOf("Jink") then
			return "$" .. card:getEffectiveId()
		end
	end
	return "."
end

sgs.bgm_ganning_suit_value =
{
    spade = 3.9,
    club = 3.9
}

sgs.ai_skill_invoke.fenyong = function(self, data)
	return true
end

sgs.ai_skill_choice.xuehen = function(self, choices)
	local current = self.room:getCurrent();
	self:sort(self.enemies, "defense")
	for _,enemy in ipairs(self.enemies) do
		local def=sgs.getDefense(enemy)
		local amr=enemy:getArmor()
		local eff=(not amr) or self.player:hasWeapon("qinggang_sword") or not
			((amr:isKindOf("Vine") and not self.player:hasWeapon("fan")))

		if self.player:canSlash(enemy, false) and not self:slashProhibit(nil, enemy) and eff and def < 8 then
			self.xuehentarget = enemy
			return "slash"
		end
	end
	if self:isFriend(current) then
		for _,enemy in ipairs(self.enemies) do
			local eff=(not amr) or self.player:hasWeapon("qinggang_sword") or not
				((amr:isKindOf("Vine") and not self.player:hasWeapon("fan")))

			if self.player:canSlash(enemy, false) and not self:slashProhibit(nil, enemy) then
				self.xuehentarget = enemy
				return "slash"
			end
		end
	end
	return "discard"
end

sgs.ai_skill_playerchosen.xuehen = function(self, targets)
	return self.xuehentarget
end
