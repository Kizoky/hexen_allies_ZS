#include "zscript/AllyMenu_ZF/HA.AllyMenu_Handler.ZS"
#include "zscript/AllyMenu_ZF/HA.AllyMenu.InfoDialog.ZS"
#include "zscript/AllyMenu_ZF/HA.AllyMenu.SettingsDialog.ZS"

class HXA_AllyMenu : HXA_ZF_GenericMenu
{
	Font smallFont;
	
	HXA_ZF_Image background;
	
	// Automatically generated
	Array<HXA_ZF_Label> allyNameLabels;
	Array<HXA_ZF_Button> allyNameButtons;
	
	HXA_ZF_Frame allyFrame;
	
	HXA_ZF_Button spawnButton;
	HXA_ZF_Button incrementButton;
	HXA_ZF_Button maxAllySlotButton;
	
	// Contains every labels or buttons that are not related to Ally names
	Array<HXA_ZF_Label> labelsContainer;
	Array<HXA_ZF_Button> buttonsContainer;
	
	HXA_ZF_ScrollContainer scrollContainer;
	
	HXA_AllyMenuHandler handler;
	
	override void handleBack()
	{
		let HubInv = HA_AIHub(players [consoleplayer].mo.FindInventory("HA_AIHub"));
		if (HubInv)
		{
			string Event = String.Format("AllyMenu_Active:%d:0", HubInv.UI_GetPlayerIndex());
			EventHandler.SendNetworkEvent(Event);
		}
		
		HXA_ZF_GenericMenu.handleBack();
	}
	
	override void Init (Menu parent)
	{
		Super.Init (parent);
		
		let HubInv = HA_AIHub(players [consoleplayer].mo.FindInventory("HA_AIHub"));
		if (HubInv)
		{
			string Event = String.Format("AllyMenu_Active:%d:1", HubInv.UI_GetPlayerIndex());
			EventHandler.SendNetworkEvent(Event);
		}
	
		menuactive = OnNoPause;
	
		// Set our base resolution to 320x200.
		SetBaseResolution ((320, 200));
	
		smallFont = Font.GetFont ("SmallFont");
	
		handler = new ("HXA_AllyMenuHandler");
		handler.link = self;
	
		string PanelBG = "graphics/ZForms/Panel.png";
		HexenAlliesCoreHandler EventHandler = HexenAlliesCoreHandler(StaticEventHandler.Find("HexenAlliesCoreHandler"));
		if (EventHandler.isHereticUI())
			PanelBG = "graphics/ZForms/HereticPanel.png";
	
		background = HXA_ZF_Image.Create
		(
			// Position.
			(0, 0),
			// Size.
			(320, 200),
			// Image path/name.
			PanelBG,
			// Alignment options.
			HXA_ZF_Image.AlignType_TopLeft
		);
		// Add the image element into the main frame.
		background.Pack (mainFrame);
	
		InitializeData();
	}
	
	// aka. DESTROY everything!
	void RefreshData()
	{
		if (bListToggled)
		{
			DestroySettingsScroll();
		}
		
		// Destroy ally labels and buttons
		while (allyNameLabels.Size () > 0)
		{
			let label = allyNameLabels [0];
			allyNameLabels.Delete (0, 1);
	
			let button = allyNameButtons [0];
			allyNameButtons.Delete (0, 1);
	
			label.Unpack ();
			label.Destroy ();
	
			button.Unpack ();
			button.Destroy ();
		}
	
		// Destroy label container
		while (labelsContainer.Size() > 0)
		{
			let label = labelsContainer [0];
			labelsContainer.Delete (0, 1);
	
			label.Unpack();
			label.Destroy();
		}
	
		// Destroy button container
		while (buttonsContainer.Size() > 0)
		{
			let button = buttonsContainer [0];
			buttonsContainer.Delete (0, 1);
	
			button.Unpack();
			button.Destroy();
		}
	
		// Destroy frame for Ally labels and names
		allyFrame.Destroy();
	
		// Destroy scroll container
		scrollContainer.Unpack();
		scrollContainer.Destroy();
	
		if (allyInfoBackground)
		{
			allyInfoBackground.Unpack();
			allyInfoBackground.Destroy();
	
			if (allyInfoFrame)
				allyInfoFrame.Destroy();
		}
		
		if (settingsBackground)
		{
			settingsBackground.Unpack();
			settingsBackground.Destroy();
			
			if (settingsFrame)
				settingsFrame.Destroy();
		}
	
		InitializeData();
	}
	
	void InitializeData()
	{
		allyFrame = HXA_ZF_Frame.Create((0, 0), (320, 200));
	
		let HubInv = HA_AIHub(players [consoleplayer].mo.FindInventory("HA_AIHub"));
		if (!HubInv)
			return;
	
		let AllySlotInv = HA_AllySlot(players [consoleplayer].mo.FindInventory("HA_AllySlot"));
		if (!AllySlotInv)
			return;
	
		let AllySpawnerInv = HA_AllySpawner(players [consoleplayer].mo.FindInventory("HA_AllySpawner"));
		if (!AllySpawnerInv)
			return;
	
		string activeAllies = String.Format("Active allies: %d/%d", HubInv.UI_ActiveAIs(), AllySlotInv.UI_AllySlots());
		AddLabelOnScreen(activeAllies, Font.CR_WHITE, 150, 128);
	
		string allySlots = String.Format("Ally slots: %d/%d", AllySlotInv.UI_AllySlots(), AllySlotInv.UI_AllySlotsMax());
		AddLabelOnScreen(allySlots, Font.CR_WHITE, 150, 140);
	
		int souls = players [consoleplayer].mo.CountInv("HA_Soul");
		string availableSouls = String.Format("Available souls: %d", souls);
		AddLabelOnScreen(availableSouls, Font.CR_WHITE, 150, 152);
	
		int upgradeRow = 24;
	
		// ----------------------------------------------------------------------------------------------
		bool spawnDisabled = ((HubInv.UI_ActiveAIs() == AllySlotInv.UI_AllySlots()) || (souls < AllySpawnerInv.UI_AllySpawnCost())) ? true : false;
		spawnButton = AddButtonOnScreen("UpgradeButton_Spawn", "graphics/ZForms/UpgradeButtonSpawn.png", 150, 165, spawnDisabled, "Spawn\nAlly");
		string spawnCost = String.Format("%d", AllySpawnerInv.UI_AllySpawnCost());
	
		if (!spawnDisabled)
			AddLabelOnScreen(spawnCost, Font.CR_GREEN, 162, 180);
		else
			AddLabelOnScreen(spawnCost, Font.CR_RED, 162, 180);
		// ----------------------------------------------------------------------------------------------
	
		// ----------------------------------------------------------------------------------------------
		bool incrementDisabled = ((AllySlotInv.UI_AllySlots() == AllySlotInv.UI_AllySlotsMax()) || (souls < AllySlotInv.UI_AllySlotCost())) ? true : false;
		incrementButton = AddButtonOnScreen("UpgradeButton_SlotUp", "graphics/ZForms/UpgradeButtonIncrement.png", 150 + (26 * 1), 165, incrementDisabled, "Increase\nSlot");
		string incrementCost = String.Format("%d", AllySlotInv.UI_AllySlotCost());
	
		if (!incrementDisabled)
			AddLabelOnScreen(incrementCost, Font.CR_GREEN, 150 + (26 * 1) + 10, 180);
		else
			AddLabelOnScreen(incrementCost, Font.CR_RED, 150 + (26 * 1) + 10, 180);
		// ----------------------------------------------------------------------------------------------
	
		// ----------------------------------------------------------------------------------------------
		bool maxAllySlotDisabled = (souls < AllySlotInv.UI_AllySlotMaxCost()) ? true : false;
		maxAllySlotButton = AddButtonOnScreen("UpgradeButton_SlotMaxUp", "graphics/ZForms/UpgradeButtonIncrementMaxSlot.png", 150 + (29 * 2), 165, maxAllySlotDisabled, "Increase\nMax Slot");
		string maxAllySlotCost = String.Format("%d", AllySlotInv.UI_AllySlotMaxCost());
	
		if (!maxAllySlotDisabled)
			AddLabelOnScreen(maxAllySlotCost, Font.CR_GREEN, 150 + (29 * 2) + 10, 180);
		else
			AddLabelOnScreen(maxAllySlotCost, Font.CR_RED, 150 + (29 * 2) + 10, 180);
		// ----------------------------------------------------------------------------------------------
	
		//AddButtonOnScreen("UpgradeButton_Placeholder", "graphics/ZForms/UpgradeButtonPlaceholder.png", 150 + (24 * 3), 165, true);
		//AddButtonOnScreen("UpgradeButton_Placeholder", "graphics/ZForms/UpgradeButtonPlaceholder.png", 150 + (24 * 4), 165, true);
		//AddButtonOnScreen("UpgradeButton_Placeholder", "graphics/ZForms/UpgradeButtonPlaceholder.png", 150 + (24 * 5), 165, true);
		
		AddButtonOnScreen("SettingsButton", "graphics/ZForms/SettingsButton.png", 7, 9, false, "", null, 22, 18);
	
		// Stats for Information
	
		HA_AIHub pHubInv = HubInv;
	
		for (uint i = 0; i < HubInv.AIinfo.size(); i++)
		{
			if (HubInv.AIinfo[i].pAlly)
			{
				let Ally = HA_CoreAI(HubInv.AIinfo[i].pAlly);
				if (Ally)
				{
					// Add Ally names and buttons
					FillAllyData(Ally.UI_AllyName(), Ally.UI_AllyColor(), Ally.UI_GetSlot(), Ally);
				}
			}
		}
	
		// Scrolling
		HXA_ZF_BoxTextures scrollBar = HXA_ZF_BoxTextures.createSingleTexture("graphics/ZForms/ScrollBar.png", false);
		HXA_ZF_BoxTextures scrollBG = HXA_ZF_BoxTextures.createSingleTexture("graphics/ZForms/ScrollBG.png", false);
		scrollContainer = HXA_ZF_ScrollContainer.Create
		(
			// pos
			(2,32), // 6 29
			// size
			(139,154), // 139 191
			// scrollWidth
			10,
			// scrollAreaHeight
			11 * allyNameLabels.Size(),
			// scrollNotchJump
			5,
			// scrollBarNormal
			scrollBar,
			scrollBg:scrollBG,
			// scrollArea
			scrollArea:allyFrame
		);
	
		scrollContainer.pack(mainFrame);
	
		HA_CoreAI pDyingAI = HubInv.GetLowestHPAlly();
		HA_CoreAI pBestKillsAI = HubInv.GetAllyByStat("Kills");
	
		if (!pDyingAI && !pBestKillsAI)
			return;
			
		int lowestHealth = pDyingAI.Health;
		int bestKills = pBestKillsAI.UI_AllyStatInt("Kills");
	
		// Add labels (non interactive ones)
		int informationrow = 1;
	
		// Lowest HP: num AIType -------------------------------------------------------------
			string dyingText;
	
			if (lowestHealth == 100)
				dyingText = String.Format("Lowest HP: n/a");
			else
				dyingText = String.Format("Lowest HP: %d", lowestHealth);
	
			AddLabelOnScreen(dyingText, Font.CR_RED, 150, 25 + (smallfont.GetHeight () - 2) * informationrow);
	
			if (lowestHealth != 100)
			{
				string dyingTextAlly = String.Format("%s %d", pDyingAI.UI_AllyType(), pDyingAI.UI_GetSlot());
				AddLabelOnScreen(dyingTextAlly, GetAllyColor(pDyingAI.UI_AllyColor()), 150 + smallfont.StringWidth (dyingText) + 4, 25 + (smallfont.GetHeight () - 3) * informationrow);
			}
		// ---------------------------------------------------------------------------------
		informationrow++;
		// Overall spawned: num ------------------------------------------------------------
				string spawnText = String.Format("Overall spawned: %d", pHubInv.UI_TotalAIsSpawned());
				AddLabelOnScreen(spawnText, Font.CR_RED, 150, 25 + (smallfont.GetHeight () - 2) * informationrow);
		// ---------------------------------------------------------------------------------
		informationrow++;
		// Total allies died: num ----------------------------------------------------------
			string deadText = String.Format("Overall dead: %d", pHubInv.UI_TotalAIsDead());
			AddLabelOnScreen(deadText, Font.CR_RED, 150, 25 + (smallfont.GetHeight () - 2) * informationrow);
		// ---------------------------------------------------------------------------------
		informationrow++;
		// Total souls spent: num ----------------------------------------------------------
			string spentText = String.Format("Souls spent: %d", pHubInv.TotalSpent);
			AddLabelOnScreen(spentText, Font.CR_RED, 150, 25 + (smallfont.GetHeight () - 2) * informationrow);
		// ---------------------------------------------------------------------------------
		informationrow++;
		// Best kills: num AIType ----------------------------------------------------------
			string killsText;
	
			if (bestKills == 0)
				killsText = String.Format("Best kills: n/a");
			else
				killsText = String.Format("Best kills: %d", bestKills);
	
			AddLabelOnScreen(killsText, Font.CR_RED, 150, 25 + (smallfont.GetHeight () - 2) * informationrow);
	
			if (bestKills != 0)
			{
				string killsTextAlly = String.Format("%s %d", pBestKillsAI.UI_AllyType(), pBestKillsAI.UI_GetSlot());
				AddLabelOnScreen(killsTextAlly, GetAllyColor(pBestKillsAI.UI_AllyColor()), 150 + smallfont.StringWidth (killsText) + 4, 25 + (smallfont.GetHeight () - 2) * informationrow);
			}
		// ---------------------------------------------------------------------------------
	}
	
	HXA_ZF_Label AddLabelOnScreen(string ttext, int tcolor, int hpos, int vpos, HXA_ZF_Frame mframe = null)
	{
		if (mframe == null)
			mframe = mainFrame;
	
		let rLabel = HXA_ZF_Label.Create
		(
			// Position.
			(
				hpos,
				vpos
			),
			// Size.
			(
				// Calculate the horizontal size of the text.
				smallfont.StringWidth (ttext),
				// Get the font's height.
				smallFont.GetHeight ()
			),
			// The label's text.
			text: ttext,
			// The font to use.
			fnt: smallFont,
			// Whether to automatically wrap the text or not.
			wrap: false,
			// Whether to automatically resize the element based on the text width.
			autoSize: true,
			// The text's colour.
			textColor: tcolor
		);
		rLabel.Pack (mframe);
	
		labelsContainer.Push(rLabel);
	
		return rLabel;
	}
	
	HXA_ZF_Button AddButtonOnScreen(string CMD, string tex, int hpos, int vpos, bool disabled = false, string hoverText = "", HXA_ZF_Frame mframe = null, int hsize = 20, int vsize = 24)
	{
		if (mframe == null)
			mframe = mainFrame;
	
		// ----------------------------------------------------------------------------
		string UpgradeButtonCMD = String.Format(CMD);
		let button = HXA_ZF_Button.Create
		(
			// Position
			(
				hpos,
	
				vpos
			),
			// Size
			(hsize, vsize),
	
			text: hoverText,
	
			// Our command handler
			cmdHandler: handler,
	
			
			// A command string for the button
			command: UpgradeButtonCMD,
			textScale: 0.27,
			alignment: HXA_ZF_Button.AlignType_TopLeft
		);
	
		HXA_ZF_BoxTextures ButtonIdle = HXA_ZF_BoxTextures.createSingleTexture(tex, false);
	
		string texHover = tex;
		string texClick = tex;
		string texDisabled = tex;
	
		texHover.Replace(".png", "_HOVER.png");
		texClick.Replace(".png", "_CLICK.png");
		texDisabled.Replace(".png", "_DISABLED.png");
	
		HXA_ZF_BoxTextures ButtonHover = HXA_ZF_BoxTextures.createSingleTexture(texHover, false);
		HXA_ZF_BoxTextures ButtonClick = HXA_ZF_BoxTextures.createSingleTexture(texClick, false);
		HXA_ZF_BoxTextures ButtonDisabled = HXA_ZF_BoxTextures.createSingleTexture(texDisabled, false);
	
		// Set the button's textures.
		button.SetTextures
		(
			// Idle/inactive
			ButtonIdle,
			// Hovered
			ButtonHover,
			// Clicked/pressed
			ButtonClick,
			// Disabled
			ButtonDisabled
		);
	
		if (disabled)
			button.Disable();
	
		button.Pack (mframe);
	
		buttonsContainer.Push(button);
	
		return button;
	}
	
	// from string to int
	int GetAllyColor(string AllyColor)
	{
		int iAllyColor = Font.CR_WHITE;
	
		if (AllyColor ~== "Green") 
			iAllyColor = Font.CR_GREEN;
		if (AllyColor ~== "Red")
			iAllyColor = Font.CR_RED;
		if (AllyColor ~== "Blue")
			iAllyColor = Font.CR_BLUE;
		if (AllyColor ~== "Silver")
			iAllyColor = Font.CR_WHITE;
		if (AllyColor ~== "Yellow")
			iAllyColor = Font.CR_YELLOW;
	
		return iAllyColor;
	}
	
	void FillAllyData (string AllyTag, string AllyColor, int AllySpawnSlot, HA_CoreAI pAlly = null)
	{
		int verticalPos = ((smallfont.GetHeight () - 2) * allyNameLabels.size());
	
		int iAllyColor = GetAllyColor(AllyColor);
	
		string followOguard = (pAlly.Following) ? "F" : "G";
		AllyTag = String.Format("%s %d (%s)", AllyTag, AllySpawnSlot, followOguard);
	
		// Add a label.
		let label = HXA_ZF_Label.Create
		(
			// Position.
			(
				// Horizontal position.
				10,
				// Calculate the vertical position.
				// Initial offset + ((label text height + spacing) * label count)
				verticalPos
			),
			// Size.
			(
				// Calculate the horizontal size of the text.
				smallfont.StringWidth (AllyTag),
				// Get the font's height.
				smallFont.GetHeight ()
			),
			// The label's text.
			text: AllyTag,
			// The font to use.
			fnt: smallFont,
			// Whether to automatically wrap the text or not.
			wrap: false,
			// Whether to automatically resize the element based on the text width.
			autoSize: true,
			// The text's colour.
			textColor: iAllyColor
		);
		label.Pack (allyFrame);
	
		// ----------------------------------------------------------------------------
		string AllyButtonCMD = String.Format("AllyButton_%d", AllySpawnSlot);
		let button = HXA_ZF_Button.Create
		(
			// Position
			(
				10,
	
				verticalPos
			),
			// Size
			(smallfont.StringWidth (AllyTag), smallfont.GetHeight () - 2),
			// Our command handler
			cmdHandler: handler,
			// A command string for the button
			command: AllyButtonCMD
		);
	
		// We don't need a button idle for this
		HXA_ZF_BoxTextures ButtonIdle = null;
		HXA_ZF_BoxTextures ButtonHover = HXA_ZF_BoxTextures.createSingleTexture("graphics/ZForms/AllyButtonHovered.png", false);
		HXA_ZF_BoxTextures ButtonClick = HXA_ZF_BoxTextures.createSingleTexture("graphics/ZForms/AllyButtonClicked.png", false);
		HXA_ZF_BoxTextures ButtonDisabled = HXA_ZF_BoxTextures.createSingleTexture("graphics/ZForms/AllyButtonDisabled.png", false);
	
		// Set the button's textures.
		button.SetTextures
		(
			// Idle/inactive
			ButtonIdle,
			// Hovered
			ButtonHover,
			// Clicked/pressed
			ButtonClick,
			// Disabled
			ButtonDisabled
		);
		button.Pack (allyFrame);
	
		allyNameLabels.Push (label);
		allyNameButtons.Push (button);
	}
	
	int internalTimer;
	bool shouldRefresh;
	bool shouldRefreshPlay;
	override void Ticker ()
	{
		if (shouldRefresh /*|| (level.time % (35 * 1) == 0)*/)
		{
			// Give a few miliseconds for the Menu to "refresh"
			internalTimer++;
			if (internalTimer == 5)
			{
				internalTimer = 0;
				RefreshData();
				shouldRefresh = false;
			}
		}
		else if (shouldRefreshPlay)
		{
			// Give a few miliseconds for the Menu to "refresh"
			internalTimer++;
			if (internalTimer == 5)
			{
				let HubInv = HA_AIHub(players [consoleplayer].mo.FindInventory("HA_AIHub"));
				if (HubInv && HubInv.ForceRefresh)
				{
					string Event = String.Format("AllyMenu_StopUIRefresh:%d", HubInv.UI_GetPlayerIndex());
					EventHandler.SendNetworkEvent(Event);
					internalTimer = 0;
					RefreshData();
					shouldRefreshPlay = false;
				}
			}
		}
		else
		{
			let HubInv = HA_AIHub(players [consoleplayer].mo.FindInventory("HA_AIHub"));
			if (HubInv)
			{
				if (HubInv.ForceRefresh)
				{
					shouldRefreshPlay = true;
				}
			}
		}
	
		Super.Ticker();
	}
}