// The settings menu that brings up when you press the gear icon on the top left corner

extend class HXA_AllyMenu
{
    HXA_ZF_Image settingsBackground;
    HXA_ZF_Frame settingsFrame;
	HXA_ZF_Frame settingsScrollFrame;

    bool settingsOpen;

    Array<HXA_ZF_Label> settingsLabelsContainer;
    Array<HXA_ZF_Button> settingsButtonsContainer;
	
	HXA_ZF_ScrollContainer settingsScrollContainer;
	Array<HXA_ZF_Label> scrollLabelsContainer;
	Array<HXA_ZF_Button> scrollLabelsButtons;
	
	void RefreshSettingsDialog()
	{
		CloseSettingsDialog();
		CreateSettingsDialog();
	}
	
    void CloseSettingsDialog()
    {
		DestroySettingsScroll();
		
		if (settingsBackground)
		{
			settingsBackground.Unpack();
			settingsBackground.Destroy();
		}
		
		while (settingsButtonsContainer.Size() > 0)
		{
			let button = settingsButtonsContainer [0];
			settingsButtonsContainer.Delete (0, 1);
		
			button.Unpack();
			button.Destroy();
		}
		
		// Destroy label container
		while (settingsLabelsContainer.Size() > 0)
		{
			let label = settingsLabelsContainer [0];
			settingsLabelsContainer.Delete (0, 1);
		
			label.Unpack();
			label.Destroy();
		}
		
		if (settingsFrame)
		{
			settingsFrame.Unpack();
			settingsFrame.Destroy();
		}
		
        settingsOpen = false;
		bListToggled = false;
    }

	void AddSettingsColorLabelAndButton(string sColor)
	{
		int iColor = Font.CR_WHITE;
	
		if (sColor ~== "Red")
			iColor = Font.CR_RED;
		if (sColor ~== "Dark Red")
			iColor = Font.CR_DARKRED;
		if (sColor ~== "Light Red")
			iColor = Font.CR_FIRE;
		if (sColor ~== "Blue")
			iColor = Font.CR_BLUE;
		if (sColor ~== "Dark Blue")
			iColor = Font.CR_ICE;
		if (sColor ~== "Light Blue")
			iColor = Font.CR_LIGHTBLUE;
		if (sColor ~== "Green") 
			iColor = Font.CR_GREEN;
		if (sColor ~== "Dark Green") 
			iColor = Font.CR_DARKGREEN;
		if (sColor ~== "Yellow")
			iColor = Font.CR_YELLOW;
		//if (sColor ~== "Dark Yellow")
			//iColor = Font.CR_DARKYELLOW;
		if (sColor ~== "Gray")
			iColor = Font.CR_GRAY;
		if (sColor ~== "Dark Gray")
			iColor = Font.CR_DARKGRAY;
		//if (sColor ~== "Pink")
			//iColor = Font.CR_PINK;
		if (sColor ~== "Black")
			iColor = Font.CR_BLACK;
		if (sColor ~== "Brown")
			iColor = Font.CR_BROWN;
		if (sColor ~== "Purple")
			iColor = Font.CR_PURPLE;
		if (sColor ~== "Orange")
			iColor = Font.CR_ORANGE;
	
		int verticalPos = ((smallfont.GetHeight () - 2) * scrollLabelsContainer.size());
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
				smallfont.StringWidth (sColor),
				// Get the font's height.
				smallFont.GetHeight ()
			),
			// The label's text.
			text: sColor,
			// The font to use.
			fnt: smallFont,
			// Whether to automatically wrap the text or not.
			wrap: false,
			// Whether to automatically resize the element based on the text width.
			autoSize: true,
			// The text's colour.
			textColor: iColor
		);
		
		label.Pack (settingsScrollFrame);
		
		scrollLabelsContainer.Push(label);
		
		///////////////////////////////////////////////////////////////////////////////////////////
		
		string CMD = String.Format("MPColorButton_%d", scrollLabelsContainer.size()-1);
		let button = HXA_ZF_Button.Create
		(
			// Position
			(
				10,
	
				verticalPos
			),
			// Size
			(smallfont.StringWidth (sColor), smallfont.GetHeight () - 2),
			// Our command handler
			cmdHandler: handler,
			// A command string for the button
			command: CMD
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
		button.Pack (settingsScrollFrame);
		
		scrollLabelsButtons.Push(button);
	}

	bool bListToggled;
	
	void DestroySettingsScroll()
	{
		for (int i = 0; i < scrollLabelsButtons.Size(); i++)
		{
			let button = scrollLabelsButtons[i];
			if (button)
			{
				button.Unpack();
				button.Destroy();
			}
		}
		scrollLabelsButtons.Clear();
		
		for (int i = 0; i < scrollLabelsContainer.Size(); i++)
		{
			let label = scrollLabelsContainer[i];
			if (label)
			{
				label.Unpack();
				label.Destroy();
			}
		}
		scrollLabelsContainer.Clear();
		
		// Destroy scroll container
		if (settingsScrollContainer)
		{
			settingsScrollContainer.Unpack();
			settingsScrollContainer.Destroy();
		}
		
		bListToggled = false;
	}
	
	void ToggleColorList()
	{
		if (bListToggled)
		{
			DestroySettingsScroll();
			return;
		}
		
		// Scrolling
		settingsScrollFrame = HXA_ZF_Frame.Create((50, 35), (220, 150));
		
		// This is absolutely criminal
		AddSettingsColorLabelAndButton("White");
		AddSettingsColorLabelAndButton("Red");
		AddSettingsColorLabelAndButton("Dark Red");
		AddSettingsColorLabelAndButton("Light Red");
		AddSettingsColorLabelAndButton("Blue");
		AddSettingsColorLabelAndButton("Dark Blue");
		AddSettingsColorLabelAndButton("Light Blue");
		AddSettingsColorLabelAndButton("Green");
		AddSettingsColorLabelAndButton("Dark Green");
		AddSettingsColorLabelAndButton("Yellow");
		AddSettingsColorLabelAndButton("Dark Yellow");
		AddSettingsColorLabelAndButton("Gray");
		AddSettingsColorLabelAndButton("Dark Gray");
		AddSettingsColorLabelAndButton("Pink");
		AddSettingsColorLabelAndButton("Silver");
		AddSettingsColorLabelAndButton("Black");
		AddSettingsColorLabelAndButton("Brown");
		AddSettingsColorLabelAndButton("Purple");
		AddSettingsColorLabelAndButton("Orange");
		
		// Has to be done last
		HXA_ZF_BoxTextures scrollBar = HXA_ZF_BoxTextures.createSingleTexture("graphics/ZForms/ScrollBar.png", false);
		HXA_ZF_BoxTextures scrollBG = HXA_ZF_BoxTextures.createSingleTexture("graphics/ZForms/ScrollBG.png", false);
		settingsScrollContainer = HXA_ZF_ScrollContainer.Create
		(
			// pos
			(55,52), // 6 29
			// size
			(139,120), // 139 191
			// scrollWidth
			10,
			// scrollAreaHeight
			11 * scrollLabelsContainer.size(),
			// scrollNotchJump
			5,
			// scrollBarNormal
			scrollBar,
			scrollBg:scrollBG,
			// scrollArea
			scrollArea:settingsScrollFrame
		);
	
		settingsScrollContainer.pack(mainFrame);
		
		bListToggled = true;
	}

    void CreateSettingsDialog()
    {
        let HubInv = HA_AIHub(players [consoleplayer].mo.FindInventory("HA_AIHub"));
        if (!HubInv)
            return;
		
        settingsOpen = true;

        settingsFrame = HXA_ZF_Frame.Create((50, 35), (220, 150));
        settingsFrame.Pack (mainFrame);

        settingsBackground = HXA_ZF_Image.Create
        (
            // Position.
            (0, 0),
            // Size.
            (220, 150),
            // Image path/name.
            "graphics/ZForms/settingsdialog.png",
            // Alignment options.
            HXA_ZF_Image.AlignType_TopLeft
        );
        settingsBackground.Pack (settingsFrame);


		string MPColorText = "MP Color: n/a";
		
		// Grab color from cvar
		cvar logocolorcvar = cvar.getcvar("hxa_logocolor", HubInv.Owner.Player);
		if (logocolorcvar)
		{
			string color = HA_AIHub.MpLogoColors[logocolorcvar.GetInt()];
			MPColorText = String.Format("MP Color: %s", color);
		}
	
		// 0
        settingsLabelsContainer.Push(AddLabelOnScreen(MPColorText, Font.CR_WHITE, 7, 7, settingsFrame));
		
		string CMD = "Settings_MPColor";
		let button = HXA_ZF_Button.Create
		(
			// Position
			(
				7,
	
				7
			),
			// Size
			(smallfont.StringWidth (MPColorText), smallfont.GetHeight () - 2),
			// Our command handler
			cmdHandler: handler,
			// A command string for the button
			command: CMD
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
		button.Pack (settingsFrame);
		
		settingsButtonsContainer.Push(button);
		
		//AddButtonOnScreen("Settings_MPColor", "graphics/ZForms/SettingsButton.png", 7, 7, false, "", null, 22, 18);
		
		
    }
}