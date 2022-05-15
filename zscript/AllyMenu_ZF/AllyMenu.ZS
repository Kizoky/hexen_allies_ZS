class HXA_AllyMenu : HXA_ZF_GenericMenu
{
    Font smallFont;

    HXA_ZF_Image background;

    // Automatically generated
    Array<HXA_ZF_Label> allyNameLabels;
    Array<HXA_ZF_Button> allyNameButtons;

    HXA_ZF_Button spawnButton;
    HXA_ZF_Button incrementButton;
    HXA_ZF_Button maxAllySlotButton;

    // Contains every labels or buttons that are not related to Ally names
    Array<HXA_ZF_Label> labelsContainer;
    Array<HXA_ZF_Button> buttonsContainer;

    HXA_AllyMenuHandler handler;

    override void Init (Menu parent)
    {
        Super.Init (parent);

        // Set our base resolution to 320x200.
        SetBaseResolution ((320, 200));

        smallFont = Font.GetFont ("SmallFont");

        handler = new ("HXA_AllyMenuHandler");
        handler.link = self;

        background = HXA_ZF_Image.Create
        (
            // Position.
            (0, 0),
            // Size.
            (320, 200),
            // Image path/name.
            "graphics/ZForms/Panel.png",
            // Alignment options.
            HXA_ZF_Image.AlignType_TopLeft
        );
        // Add the image element into the main frame.
        background.Pack (mainFrame);

        InitializeData();
    }

    void RefreshData()
    {
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

        InitializeData();
    }

    void InitializeData()
    {
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
        spawnButton = AddButtonOnScreen("UpgradeButton_Spawn", "graphics/ZForms/UpgradeButtonSpawn.png", 150, 165, spawnDisabled);
        string spawnCost = String.Format("%d", AllySpawnerInv.UI_AllySpawnCost());

        if (!spawnDisabled)
            AddLabelOnScreen(spawnCost, Font.CR_GREEN, 162, 180);
        else
            AddLabelOnScreen(spawnCost, Font.CR_RED, 162, 180);
        // ----------------------------------------------------------------------------------------------

        // ----------------------------------------------------------------------------------------------
        bool incrementDisabled = ((AllySlotInv.UI_AllySlots() == AllySlotInv.UI_AllySlotsMax()) || (souls < AllySlotInv.UI_AllySlotCost())) ? true : false;
        incrementButton = AddButtonOnScreen("UpgradeButton_SlotUp", "graphics/ZForms/UpgradeButtonIncrement.png", 150 + (26 * 1), 165, incrementDisabled);
        string incrementCost = String.Format("%d", AllySlotInv.UI_AllySlotCost());

        if (!incrementDisabled)
            AddLabelOnScreen(incrementCost, Font.CR_GREEN, 150 + (26 * 1) + 10, 180);
        else
            AddLabelOnScreen(incrementCost, Font.CR_RED, 150 + (26 * 1) + 10, 180);
        // ----------------------------------------------------------------------------------------------

        // ----------------------------------------------------------------------------------------------
        bool maxAllySlotDisabled = (souls < AllySlotInv.UI_AllySlotMaxCost()) ? true : false;
        maxAllySlotButton = AddButtonOnScreen("UpgradeButton_SlotMaxUp", "graphics/ZForms/UpgradeButtonIncrementMaxSlot.png", 150 + (29 * 2), 165, maxAllySlotDisabled);
        string maxAllySlotCost = String.Format("%d", AllySlotInv.UI_AllySlotMaxCost());

        if (!maxAllySlotDisabled)
            AddLabelOnScreen(maxAllySlotCost, Font.CR_GREEN, 150 + (29 * 2) + 10, 180);
        else
            AddLabelOnScreen(maxAllySlotCost, Font.CR_RED, 150 + (29 * 2) + 10, 180);
        // ----------------------------------------------------------------------------------------------

        //AddButtonOnScreen("UpgradeButton_Placeholder", "graphics/ZForms/UpgradeButtonPlaceholder.png", 150 + (24 * 3), 165, true);
        //AddButtonOnScreen("UpgradeButton_Placeholder", "graphics/ZForms/UpgradeButtonPlaceholder.png", 150 + (24 * 4), 165, true);
        //AddButtonOnScreen("UpgradeButton_Placeholder", "graphics/ZForms/UpgradeButtonPlaceholder.png", 150 + (24 * 5), 165, true);

        // Stats for Information
        int lowestHealth = 999;
        int bestKills = -1;
        HA_CoreAI pDyingAI;
        HA_CoreAI pBestKillsAI;

        HA_AIHub pHubInv = HubInv;

        for (uint i = 0; i < HubInv.AIinfo.size(); i++)
		{
			if (HubInv.AIinfo[i].pAlly)
			{
                let Ally = HA_CoreAI(HubInv.AIinfo[i].pAlly);
                if (Ally)
                {
                    // Add Ally names and buttons
                    FillAllyData(Ally.UI_AllyName(), Ally.UI_AllyColor(), Ally.UI_GetSlot());

                    // Ally with the lowest HP
                    if (Ally.Health < lowestHealth)
                    {
                        lowestHealth = Ally.Health;
                        pDyingAI = Ally;
                    }

                    // Ally with the best kills
                    if (Ally.UI_AllyKills() > bestKills)
                    {
                        bestKills = Ally.UI_AllyKills();
                        pBestKillsAI = Ally;
                    }
                }
            }
        }

        if (!pDyingAI && !pBestKillsAI)
            return;

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
            string spentText = String.Format("Souls spent: %d", 5 * pHubInv.UI_TotalAIsSpawned());
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

    HXA_ZF_Label AddLabelOnScreen(string ttext, int tcolor, int hpos, int vpos)
    {
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
        rLabel.Pack (mainFrame);

        labelsContainer.Push(rLabel);

        return rLabel;
    }

    HXA_ZF_Button AddButtonOnScreen(string CMD, string tex, int hpos, int vpos, bool disabled = false)
    {
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
            (20, 24),
            // Our command handler
            cmdHandler: handler,
            // A command string for the button
            command: UpgradeButtonCMD
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

        button.Pack (mainFrame);

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

    void FillAllyData (string AllyTag, string AllyColor, int AllySpawnSlot)
    {
        int verticalPos = 35 + ((smallfont.GetHeight () - 2) * allyNameLabels.size());

        int iAllyColor = GetAllyColor(AllyColor);

        AllyTag = String.Format("%s %d", AllyTag, AllySpawnSlot);

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
        label.Pack (mainFrame);

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
        button.Pack (mainFrame);

        allyNameLabels.Push (label);
        allyNameButtons.Push (button);
    }

    int internalTimer;
    bool shouldRefresh;
    override void Ticker ()
    {
        if (shouldRefresh)
        {
            // Give a few miliseconds for the Menu to "refresh"
            internalTimer++;
            if (internalTimer == 2)
            {
                RefreshData();
                internalTimer = 0;
                shouldRefresh = false;
            }
        }

        Super.Ticker();
    }
}

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

            Console.Printf("Click AllySlot: %d", AllySlot);
        }

        if (cmd ~== "UpgradeButton_Spawn")
        {
            EventHandler.SendNetworkEvent("AllyMenu_Spawn");
            link.shouldRefresh = true;
            S_StartSound("MysticIncant",CHAN_VOICE,CHANF_UI,volume:snd_menuvolume);
        }

        if (cmd ~== "UpgradeButton_SlotUp")
        {
            EventHandler.SendNetworkEvent("AllyMenu_Increment");
            link.shouldRefresh = true;
            S_StartSound("MysticIncant",CHAN_VOICE,CHANF_UI,volume:snd_menuvolume);
        }

        if (cmd ~== "UpgradeButton_SlotMaxUp")
        {
            EventHandler.SendNetworkEvent("AllyMenu_IncrementMaxSlot");
            link.shouldRefresh = true;
            S_StartSound("MysticIncant",CHAN_VOICE,CHANF_UI,volume:snd_menuvolume);
        }

        /*
		if (command == "ConfirmButton")
        {
            // Change the text's colour to a random colour.
            link.Close();
        }
        */
    }
}