do
	local attributes = 
	{ 
		area = "left",
		pushable = 1,
	};
	RegisterUIPanel(HousingBulletinBoardFrame, attributes);
    attributes.pushable = 3;
	RegisterUIPanel(NeighborhoodSettingsFrame, attributes);
	RegisterUIPanel(HousingInviteResidentFrame, attributes);

end