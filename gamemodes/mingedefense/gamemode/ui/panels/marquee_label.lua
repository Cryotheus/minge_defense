local PANEL = {}

AccessorFunc(PANEL, "Font", "Font", FORCE_STRING)
AccessorFunc(PANEL, "Speed", "Speed", FORCE_NUMBER)
AccessorFunc(PANEL, "Text", "Text", FORCE_STRING)
AccessorFunc(PANEL, "TextColor", "TextColor")
AccessorFunc(PANEL, "TextSeperator", "TextSeperator", FORCE_STRING)

function PANEL:Init()
	self:SetFont()
	self:SetSpeed(24)
	self:SetText()
	self:SetTextColor(color_white)
	
	self.DrawnText = ""
	self.TextHeight = 0
	self.TextWidth = 0
	self.TextSeperator = "	"
end

function PANEL:Paint(width, height) self:PaintText(width, height) end

function PANEL:PaintText(width, height)
	local scroll = RealTime() * self.Speed
	
	draw.SimpleText(self.DrawnText, self.Font, -(scroll % self.TextWidth), height * 0.5, self.TextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

function PANEL:PerformLayout(width, height)
	surface.SetFont(self.Font)
	
	local text_width, text_height = surface.GetTextSize(self.Text .. self.TextSeperator)
	
	--math.ceil is not sufficient? it sometimes doesn't work
	self.DrawnText = string.rep(self.Text, math.ceil(width / text_width) + 1, self.TextSeperator) .. self.TextSeperator
	self.TextWidth, self.TextHeight = text_width, text_height
end

function PANEL:SetFont(font)
	self:InvalidateLayout()
	
	self.Font = font or "DermaDefault"
end

function PANEL:SetText(text)
	self:InvalidateLayout()
	
	self.Text = text or "Marquee Label"
end

function PANEL:SetTextSeperator(text) self.TextSeperator = string.Left(text, 1) == "#" and language.GetPhrase(text) or text end

derma.DefineControl("MDMarqueeLabel", "Scrolling marquee text label.", PANEL, "DPanel")