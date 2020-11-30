--global functions
function AddPrintNameToLanguage(ent_structure)
	--given the ENT structure, automatically add the PrintName to the language
	local minge_class_path = string.Split(ent_structure.Folder, "/")
	
	language.Add(minge_class_path[#minge_class_path], ent_structure.PrintName)
end