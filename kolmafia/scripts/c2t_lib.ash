//c2t_lib
//c2t

//just a collection of functions shared between 2 or more scripts of mine


//assert
void c2t_assert(boolean val);
void c2t_assert(boolean val,string str);

//whitelist a player to a clan
//-player must be complete player name
//-level is guild rank as shown in HTML form; probably requires manual checking of the page's source to know for sure what to give other than the default of rank 0
//-show will print success/failure result in CLI
boolean c2t_whitelist(string player);
boolean c2t_whitelist(string player,int level);
boolean c2t_whitelist(string player,int level,boolean show);

//join a clan
//-string as argument uses a chat command via the CLI to join, which is unreliable
//-the other makes use of visit_url() and a clan's ID number
//returns whether successful or not
boolean c2t_joinClan(string name);
boolean c2t_joinClan(int id);

//returns whether a free vote monster is now or not
boolean c2t_isVoterNow();
//returns odds of sausage goblin next turn; value of 1 is highest
float c2t_sausageGoblinOdds();
//returns whether the next fight can be a guaranteed kramco goblin or not
boolean c2t_isSausageGoblinNow();

//set choiceAdventure#
void c2t_setChoice(int adv,int choice);

//priority
//returns first item that is present
//returns $item[none] if none present
item c2t_priority(item it1,item it2,item it3,item it4,item it5,item it6);
item c2t_priority(item it1,item it2,item it3,item it4,item it5);
item c2t_priority(item it1,item it2,item it3,item it4);
item c2t_priority(item it1,item it2,item it3);
item c2t_priority(item it1,item it2);
//should handle a mafia-limited number of items with input of $items[item1,item2,...]
item c2t_priority(boolean[item] ite);
familiar c2t_priority(boolean[familiar] fam);

//drops hardcore
void c2t_dropHardcore();

//uses a pocket wish to enter combat with mon
//returns whether combat was entered or not
boolean c2t_wishFight(monster mon);

//returns whether buf signals combat
boolean c2t_enteredCombat(buffer buf);
boolean c2t_enteredCombat(string str);

//returns weight of familiar with current buffs, etc
int c2t_famWeight(familiar fam);

//returns max number of copies pocket professor can do with current buffs, etc.
int c2t_maxProfCopy();
int c2t_maxProfCopy(int weight);
//shows max number of copies with meteor showered effect
int c2t_maxProfCopy(boolean withMeteor);

//---
// BALLS builder
// functions here are used to translate things like skill use into BALLS macro form
// all functions with "macro" argument return the same as the non-"macro" one, but with "macro" prepended to it

//combine/append
string c2t_bb(string macro,string str);
//just in case
string c2t_bb(string macro);
//finite repetition of a skill
string c2t_bb(int num,skill ski);
string c2t_bb(string macro,int num,skill ski);
//single skill
string c2t_bb(skill ski);
string c2t_bb(string macro,skill ski);
//combat item(s)
string c2t_bb(item it1);
string c2t_bb(string macro,item it1);
//funkslinging
string c2t_bb(item it1,item it2);
string c2t_bb(string macro,item it1,item it2);
//if
string c2t_bbIf(string condition,string str);
string c2t_bbIf(string macro,string condition,string str);
//while
string c2t_bbWhile(string condition,string str);
string c2t_bbWhile(string macro,string condition,string str);
//submit the macro in combat
string c2t_bbSubmit(string macro);



/*=======================================================
  below is the implementation of the above declarations
=======================================================*/


//assert
void c2t_assert(boolean val) {
	c2t_assert(val,"assertion failed");
}
void c2t_assert(boolean val,string str) {
	if (!val) abort(str);
}

//internal whitelist functions //purposely not declared above to try to not confuse
buffer _c2t_whitelist(string player,int level) {
	return visit_url("clan_whitelist.php?pwd&action=add&title=autoadd&level="+level+"&addwho="+player,true,true);
}
buffer _c2t_whitelist(string player) {
	return _c2t_whitelist(player,0); //0 should be default level by default for most clans?
}

//external whitelist functions
boolean c2t_whitelist(string player) {
	return c2t_whitelist(player,0); //0 should be default level by default for most?
}
boolean c2t_whitelist(string player,int level) {
	return c2t_whitelist(player,level,true);
}
boolean c2t_whitelist(string player,int level,boolean show) {
	string temppage = _c2t_whitelist(player,level);
	if (temppage.contains_text(" added to whitelist.")) {
		if (show) print(player+" successfully added","blue");
		return true;
	}
	else if (temppage.contains_text("That player is already on the whitelist.")) {
		if (show) print(player+" was already whitelisted","blue");
		return true;
	}
	print("Error trying to whitelist "+player,"red");
	return false;
}


boolean c2t_joinClan(int id) {
	if (get_clan_id() != id)
		visit_url("showclan.php?pwd&action=joinclan&confirm=checked&whichclan="+id,true,true);
	return (get_clan_id() == id);
}
boolean c2t_joinClan(string name) {
	if (!to_lower_case(get_clan_name()).contains_text(to_lower_case(name)))
		chat_macro("/whitelist "+name);
	return (to_lower_case(get_clan_name()).contains_text(to_lower_case(name)));
}

boolean c2t_isVoterNow() {
	if(get_property("lastVoteMonsterTurn").to_int() >= total_turns_played())
		return false;
	if ((total_turns_played() % 11) != 1)
		return false;
	if (available_amount($item[&quot;I voted!&quot; sticker]) == 0)
		return false;
	if (get_property("_voteFreeFights").to_int() >= 3)
		return false;
	return true;
}

float c2t_sausageGoblinOdds() {
	int sausageFights = get_property('_sausageFights').to_int();
	int multiplier = max(0, sausageFights - 5);
	int lastSausageTurn = get_property('_lastSausageMonsterTurn').to_int();
	return (to_float(total_turns_played()-lastSausageTurn+1)/(5.0 + to_float(sausageFights) * 3.0 + to_float(multiplier) * to_float(multiplier) * to_float(multiplier)));
}

boolean c2t_isSausageGoblinNow() {
	int sausageFights = get_property('_sausageFights').to_int();
	int multiplier = max(0, sausageFights - 5);
	int lastSausageTurn = get_property('_lastSausageMonsterTurn').to_int();

	if (sausageFights == 0)
		return true;

	return (max(0,4+sausageFights*3+multiplier*multiplier*multiplier-total_turns_played()+lastSausageTurn) == 0);
}

void c2t_setChoice(int adv,int choice) {
	set_property(`choiceAdventure{adv}`,`{choice}`);
}


item c2t_priority(item it1,item it2,item it3,item it4,item it5,item it6) {
	if (available_amount(it1) > 0)
		return it1;
	else
		return c2t_priority(it2,it3,it4,it5,it6);
}
item c2t_priority(item it1,item it2,item it3,item it4,item it5) {
	if (available_amount(it1) > 0)
		return it1;
	else
		return c2t_priority(it2,it3,it4,it5);
}
item c2t_priority(item it1,item it2,item it3,item it4) {
	if (available_amount(it1) > 0)
		return it1;
	else
		return c2t_priority(it2,it3,it4);
}
item c2t_priority(item it1,item it2,item it3) {
	if (available_amount(it1) > 0)
		return it1;
	else
		return c2t_priority(it2,it3);
}
item c2t_priority(item it1,item it2) {
	if (available_amount(it1) > 0)
		return it1;
	else if (available_amount(it2) > 0)
		return it2;
	else
		return $item[none];
}
item c2t_priority(boolean[item] ite) {
	foreach x in ite
		if (available_amount(x) > 0)
			return x;
	return $item[none];
}
familiar c2t_priority(boolean[familiar] fam) {
	foreach x in fam
		if (have_familiar(x))
			return x;
	return $familiar[none];
}


//TODO add return whether it works or not?
void c2t_dropHardcore() {
	visit_url('account.php?pwd&actions[]=unhardcore&action=Drop Hardcore&unhardcoreconfirm=1',true,false);
}

//TODO maybe allow direct from genie bottle?
boolean c2t_wishFight(monster mon) {
	if (item_amount($item[pocket wish]) == 0)
		return false;
	if (my_hp() == 0) {
		print("Starting a wish fight at zero health will be an instant loss","red");
		return false;
	}

	int id = $item[pocket wish].to_int();

	visit_url("inv_use.php?pwd="+my_hash()+"&which=3&whichitem="+id,false,true);
	visit_url("choice.php?pwd&whichchoice=1267&option=1&wish=to fight a "+mon.manuel_name,true,true);
	return c2t_enteredCombat(visit_url("main.php",false));
}

//hopefully this resists inconsequential changes
//not really sure if both needed
boolean c2t_enteredCombat(buffer buf) {
	matcher mat = create_matcher("<!-*\\s*MONSTERID:\\s+\\d+\\s*-*>",buf);
	return mat.find();
}
boolean c2t_enteredCombat(string str) {
	matcher mat = create_matcher("<!-*\\s*MONSTERID:\\s+\\d+\\s*-*>",str);
	return mat.find();
}

//get total weight of a given familiar with current buffs, etc
int c2t_famWeight(familiar fam) {
	return familiar_weight(fam)+weight_adjustment();
}

//find out max number of pocket professor copies can be done
int c2t_maxProfCopy(int weight) {
	return floor(square_root(weight+0.001))+1+(have_equipped($item[Pocket Professor memory chip])?2:0);
}
int c2t_maxProfCopy() {
	return c2t_maxProfCopy(c2t_famWeight($familiar[pocket professor]));
}
int c2t_maxProfCopy(boolean withMeteor) {
	return c2t_maxProfCopy(c2t_famWeight($familiar[pocket professor])+(withMeteor?20:0));
}


//---
// build/use BALLS macros

//combine/append
string c2t_bb(string m,string s) {
	return m + s;
}
//just in case
string c2t_bb(string m) {
	return m;
}

//finite repetition of a skill
string c2t_bb(int num,skill ski) {
	string out;
	if (have_skill(ski))
		for i from 1 to num
			out += `skill {ski.to_int()};`;
	return out;
}
string c2t_bb(string m,int num,skill ski) {
	return m + c2t_bb(num,ski);
}
//single skill
string c2t_bb(skill ski) {
	return c2t_bb(1,ski);
}
string c2t_bb(string m,skill ski) {
	return m + c2t_bb(1,ski);
}

//combat item(s)
string c2t_bb(item it1) {
	return `use {it1.to_int()};`;
}
string c2t_bb(string m,item it1) {
	return m + c2t_bb(it1);
}
//funkslinging
string c2t_bb(item it1,item it2) {
	return `use {it1.to_int()},{it2.to_int()};`;
}
string c2t_bb(string m,item it1,item it2) {
	return m + c2t_bb(it1,it2);
}

//if
string c2t_bbIf(string c,string s) {
	return `if {c};{s}endif;`;
}
string c2t_bbIf(string m,string c,string s) {
	return m + c2t_bbIf(c,s);
}

//while
string c2t_bbWhile(string c,string s) {
	return `while {c};{s}endwhile;`;
}
string c2t_bbWhile(string m,string c,string s) {
	return m + c2t_bbWhile(c,s);
}

//submit
string c2t_bbSubmit(string m) {
	if (get_property("c2t_bb_printMacro").to_boolean())
		print(`c2t_bb macro: {m}`);
	return visit_url("fight.php?action=macro&macrotext="+m,true,false);
}

