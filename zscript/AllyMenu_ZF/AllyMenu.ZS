class HXA_AllyMenu : HXA_ZF_GenericMenu
{
    Font smallFont;

    HXA_ZF_Image background;

    Array<HXA_ZF_Label> allyNameLabels;

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

        let HubInv = HA_AIHub(players [consoleplayer].mo.FindInventory("HA_AIHub"));
        if (!HubInv)
            return;

        AddLabelOnScreen("Active allies: x/5", Font.CR_WHITE, 150, 128);
        AddLabelOnScreen("Ally slots: x/5", Font.CR_WHITE, 150, 140);
        AddLabelOnScreen("Available souls: n/a", Font.CR_WHITE, 150, 152);
        AddButtonOnScreen("UpgradeButton_Spawn", "graphics/ZForms/UpgradeButtonSpawn.png", 150, 165);
        AddButtonOnScreen("UpgradeButton_SlotUp", "graphics/ZForms/UpgradeButtonIncrement.png", 174, 165);

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

        // Lowest HP: num AIType
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
        //
        informationrow++;
        // Overall spawned: num
             string spawnText = String.Format("Overall spawned: %d", pHubInv.UI_TotalAIsSpawned());
             AddLabelOnScreen(spawnText, Font.CR_RED, 150, 25 + (smallfont.GetHeight () - 2) * informationrow);
        //
        informationrow++;
        // Total allies died: num
            string deadText = String.Format("Overall dead: %d", pHubInv.UI_TotalAIsDead());
            AddLabelOnScreen(deadText, Font.CR_RED, 150, 25 + (smallfont.GetHeight () - 2) * informationrow);
        //
        informationrow++;
        // Total souls spent: num
            string spentText = String.Format("Souls spent: %d", 5 * pHubInv.UI_TotalAIsSpawned());
            AddLabelOnScreen(spentText, Font.CR_RED, 150, 25 + (smallfont.GetHeight () - 2) * informationrow);
        //
        informationrow++;
        // Best kills: num AIType
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
        //

    }

    void AddLabelOnScreen(string ttext, int tcolor, int hpos, int vpos)
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
    }

    void AddButtonOnScreen(string CMD, string tex, int hpos, int vpos)
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
    }

    override void Ticker ()
    {
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

        /*
        if (command == "AllyButton_1")
        {
            link.Close();
        }
        */

        /*
		if (command == "ConfirmButton")
        {
            // Change the text's colour to a random colour.
            link.Close();
        }
        */
    }
}