extend class HXA_AllyMenu
{
    HXA_ZF_Image allyInfoBackground;
    HXA_ZF_Frame allyInfoFrame;

    bool infoDialogOpen;

    Array<HXA_ZF_Label> infoLabelsContainer;
    Array<HXA_ZF_Button> infoButtonsContainer;

    void CloseAllyInfoDialog()
    {
        allyInfoFrame.Unpack();
        allyInfoFrame.Destroy();
        infoDialogOpen = false;
    }

    void CreateAllyInfoDialog(int allyID)
    {
        let HubInv = HA_AIHub(players [consoleplayer].mo.FindInventory("HA_AIHub"));
        if (!HubInv)
            return;

        HA_CoreAI pInfoAI = HubInv.GetAllyByIndex(allyID);

        if (!pInfoAI)
            return;

        infoDialogOpen = true;

        allyInfoFrame = HXA_ZF_Frame.Create((110, 45), (109, 96));
        allyInfoFrame.Pack (mainFrame);

        allyInfoBackground = HXA_ZF_Image.Create
        (
            // Position.
            (0, 0),
            // Size.
            (109, 96),
            // Image path/name.
            "graphics/ZForms/allyinfodialog.png",
            // Alignment options.
            HXA_ZF_Image.AlignType_TopLeft
        );
        allyInfoBackground.Pack (allyInfoFrame);

        int iAllyColor = GetAllyColor(pInfoAI.UI_AllyColor());
        string allyName = String.Format("%s %d", pInfoAI.UI_AllyType(), allyID);
        infoLabelsContainer.Push(AddLabelOnScreen(allyName, iAllyColor, 29, 0, allyInfoFrame));

        string hpText = String.Format("Health: %d", pInfoAI.Health);
        infoLabelsContainer.Push(AddLabelOnScreen(hpText, Font.CR_RED, 7, 11, allyInfoFrame));

        string killText = String.Format("Kills: %d", pInfoAI.UI_AllyStatInt("Kills"));
        infoLabelsContainer.Push(AddLabelOnScreen(killText, Font.CR_RED, 7, 11 + (10 * 1), allyInfoFrame));

        string wepText = String.Format("Wpn: %s", pInfoAI.UI_ActiveWeapon());
        infoLabelsContainer.Push(AddLabelOnScreen(wepText, Font.CR_RED, 7, 11 + (10 * 2) - 2, allyInfoFrame));

        string statusText = String.Format("%s", pInfoAI.UI_GetStatus());
        infoLabelsContainer.Push(AddLabelOnScreen(statusText, Font.CR_WHITE, 7, 11 + (10 * 3) - 2, allyInfoFrame));

        string combatText = String.Format("%s", pInfoAI.UI_GetCombatStatus());
        infoLabelsContainer.Push(AddLabelOnScreen(combatText, Font.CR_GREEN, 7, 11 + (10 * 4) - 1, allyInfoFrame));

        // -----------------------------------------------------------------------------------
        // -----------------------------------------------------------------------------------
        bool following = pInfoAI.Following;

        string guardCMD = String.Format("InfoButton:Guard:%d", allyID);
        infoButtonsContainer.Push(AddButtonOnScreen(guardCMD, "graphics/ZForms/iconempty.png", 10, 63, !following, "Guard", allyInfoFrame));

        string followCMD = String.Format("InfoButton:Follow:%d", allyID);
        infoButtonsContainer.Push(AddButtonOnScreen(followCMD, "graphics/ZForms/iconempty.png", 10 + (23 * 1), 63, following, "Follow", allyInfoFrame));

        infoButtonsContainer.Push(AddButtonOnScreen("InfoButton:Heal", "graphics/ZForms/iconempty.png", 10 + (23 * 2), 63, true, "Heal", allyInfoFrame));
        infoButtonsContainer.Push(AddButtonOnScreen("InfoButton:Upgrade", "graphics/ZForms/iconempty.png", 10 + (23 * 3), 63, true, "Upgrade", allyInfoFrame));

        infoButtonsContainer.Push(AddButtonOnScreen("CloseButton_InfoDialog", "graphics/ZForms/AllyButtonHovered.png", 101, 0, false, "", allyInfoFrame, 20, 8));
    }
}