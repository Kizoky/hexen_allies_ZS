class HXA_AllyMenuHandler : HXA_ZF_Handler
{
	// The menu this command handler belongs to.
	// We need this to be able to do anything with our menu.
	HXA_AllyMenu link;
	
	override void buttonClickCommand (HXA_ZF_Button caller, Name command)
	{
		string cmd = command;
		if (cmd.IndexOf("AllyButton_") >= 0)
		{
			cmd.Remove(0, 11);
			int AllySlot = cmd.ToInt();
	
			link.CreateAllyInfoDialog(AllySlot);
	
			//Console.Printf("Click AllySlot: %d", AllySlot);
		}
	
		if (cmd.IndexOf("InfoButton") >= 0)
		{
			EventHandler.SendNetworkEvent(cmd);
	
			Array<String> infoCmd;
			cmd.Split(infoCmd, ":");
			if (infoCmd[1] ~== "Guard" || infoCmd[1] ~== "Follow")
			{
				link.CloseAllyInfoDialog();
				link.shouldRefresh = true;
			}
		}
	
		if (cmd ~== "CloseButton_InfoDialog")
		{
			link.CloseAllyInfoDialog();
		}
	
		if (cmd ~== "UpgradeButton_Spawn")
		{
			EventHandler.SendNetworkEvent("AllyMenu_Spawn");
			link.shouldRefresh = true;
			//S_StartSound("MysticIncant",CHAN_VOICE,CHANF_UI,volume:snd_menuvolume);
		}
	
		if (cmd ~== "UpgradeButton_SlotUp")
		{
			EventHandler.SendNetworkEvent("AllyMenu_Increment");
			link.shouldRefresh = true;
			//S_StartSound("MysticIncant",CHAN_VOICE,CHANF_UI,volume:snd_menuvolume);
		}
	
		if (cmd ~== "UpgradeButton_SlotMaxUp")
		{
			EventHandler.SendNetworkEvent("AllyMenu_IncrementMaxSlot");
			link.shouldRefresh = true;
			//S_StartSound("MysticIncant",CHAN_VOICE,CHANF_UI,volume:snd_menuvolume);
		}
	}
}