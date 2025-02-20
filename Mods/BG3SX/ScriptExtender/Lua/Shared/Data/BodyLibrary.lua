----------------------------------------------------------------------------------------------------
-- Library of Vanilla genitals for easy access (resource made available on BG3 modding) 
----------------------------------------------------------------------------------------------------

Data.BodyLibrary = {}
Data.BodyLibrary.__index = Data.BodyLibrary


-- Masc/Femme
Data.BodyLibrary.BodyType = {
    [0] = "M", -- Male
    [1] = "F" -- Female
}

-- Strong is only for humanoids
Data.BodyLibrary.BodyShape = {
    [0] = "Med",
    [1] = "Tall",
    [2] = "Small", -- Custom
    [3] = "Tiny" -- Custom
}

Data.BodyLibrary.Genitals = {
    ["VULVA"] = "a0738fdf-ca0c-446f-a11d-6211ecac3291",
    ["PENIS"] = "d27831df-2891-42e4-b615-ae555404918b"
}

-- Define Data.BodyLibrary.Races dictionary
Data.BodyLibrary.Races = {
    ["899d275e-9893-490a-9cd5-be856794929f"] = "HUMANOID",
    ["0eb594cb-8820-4be6-a58d-8be7a1a98fba"] = "HUMAN",
    ["bdf9b779-002c-4077-b377-8ea7c1faa795"] = "GITHYANKI",
    ["b6dccbed-30f3-424b-a181-c4540cf38197"] = "TIEFLING",
    ["6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a"] = "ELF",
    ["45f4ac10-3c89-4fb2-b37d-f973bb9110c0"] = "HALF-ELF",
    ["0ab2874d-cfdc-405e-8a97-d37bfbb23c52"] = "DWARF",
    ["78cd3bcc-1c43-4a2a-aa80-c34322c16a04"] = "HALFLING",
    ["f1b3f884-4029-4f0f-b158-1f9fe0ae5a0d"] = "GNOME",
    ["4f5d1434-5175-4fa9-b7dc-ab24fba37929"] = "DROW",
    ["9c61a74a-20df-4119-89c5-d996956b6c66"] = "DRAGONBORN",
    ["5c39a726-71c8-4748-ba8d-f768b3c11a91"] = "HALF-ORC",
}

Data.BodyLibrary.RaceTags = {
    ["69fd1443-7686-4ca9-9516-72ec0b9d94d7"] = "HUMAN",
    ["677ffa76-2562-4217-873e-2253d4720ba4"] = "GITHYANKI",
    ["aaef5d43-c6f3-434d-b11e-c763290dbe0c"] = "TIEFLING",
    ["351f4e42-1217-4c06-b47a-443dcf69b111"] = "ELF",
    ["34317158-8e6e-45a2-bd1e-6604d82fdda2"] = "HALF-ELF",
    ["486a2562-31ae-437b-bf63-30393e18cbdd"] = "DWARF",
    ["b99b6a5d-8445-44e4-ac58-81b2ee88aab1"] = "HALFLING",
    ["1f0551f3-d769-47a9-b02b-5d3a8c51978c"] = "GNOME",
    ["a672ac1d-d088-451a-9537-3da4bf74466c"] = "DROW",
    ["3311a9a9-cdbc-4b05-9bf6-e02ba1fc72a3"] = "HALF-ORC",
    ["02e5e9ed-b6b2-4524-99cd-cb2bc84c754a"] = "DRAGONBORN",
}


--TODO: overhaul modded races support with new race and bodytype system 
-- TODO WHITELIST SPECIFIC CUSTOM Data.BodyLibrary.Races TO ALLOW SEX
-- bt3 / bt4 are bodyshape overrdes - TODO - check if this can be automated
Data.BodyLibrary.ModdedRaces = {
    {
        uuid = "ca1c9216-a0cf-44e7-811a-2f9081c536ed",
        name = "GITHZERAI",
        useDefault = true,
        defaultName = "GITHYANKI",
        default = "bdf9b779-002c-4077-b377-8ea7c1faa795",
        bs3 = 0 , bs4 = 0
    },
    {
        -- Emerald asked to exclude them from receiving genitals
        uuid = "cd852310-e3e0-4045-82a9-069bff5e1930",
        name = "CatBug",
        useDefault = true,
        defaultName = "",
        default = "",
        bs3 = 0 , bs4 = 0
    },
    {
        -- if they receive genitals they have "dickface"
        uuid = "d1be3a1a-543c-44d4-aa81-9b59c2391ff4",
        name = "Imp",
        useDefault = true,
        defaultName = "",
        default = "",
        bs3 = 0 , bs4 = 0
    },
    {
        -- if they receive genitals they have "dickface"
        uuid = "158b8943-5e9d-4e16-ad71-9f7ef2eb8e87",
        name = "Mephit",
        useDefault = true,
        defaultName = "",
        default = "",
        bs3 = 0 , bs4 = 0
    },
}

-- index, name, race, body are human readable contents
-- genitalID, raceID, bodyID are machine readable

---------------------------------------------------------------------------------------------------------

--                                        VANILLA VULVAS

---------------------------------------------------------------------------------------------------------

Data.BodyLibrary.VULVA = {

    -- Dwarves
    {   index = 1, name = "Vulva", race = "Dwarf", visual = "DWR_F_NKD_Body_Genital_A",
        genitalID = "4d4101c7-6acc-4174-a1e9-51f72837ebfa",
        raceID = "0ab2874d-cfdc-405e-8a97-d37bfbb23c52",
        visualID = "7058e55a-5d40-fbce-0662-671eb6529de8"
    },
    {   index = 2, name = "Default", race = "Dwarf", visual = "DWR_F_NKD_Body_Genital_A",
        genitalID = "f270fb31-60a0-476b-9d59-bda6a4bbd9de",
        raceID = "0ab2874d-cfdc-405e-8a97-d37bfbb23c52",
        visualID = "7058e55a-5d40-fbce-0662-671eb6529de8"
    },
    {   index = 3, name = "Vulva_B", race = "Dwarf", visual = "DWR_F_NKD_Body_Genital_A_NoHair",
        genitalID = "59da5932-ffd2-45ba-8993-51f4a3cd040c",
        raceID = "0ab2874d-cfdc-405e-8a97-d37bfbb23c52",
        visualID = "37a94b45-e1a3-42bd-c76d-f42b085ad74e"
    },
    {   index = 4, name = "Vulva", race = "Dwarf", visual = "DWR_M_NKD_Body_Genital_A",
        genitalID = "72430fea-3ad2-48dc-9948-a8f39596013c",
        raceID = "0ab2874d-cfdc-405e-8a97-d37bfbb23c52",
        visualID = "dc9f7e94-a634-2009-5788-775e4ef26d62"
    },
    {   index = 5, name = "Default", race = "Dwarf", visual = "DWR_M_NKD_Body_Genital_A",
        genitalID = "bb9227ca-72e7-4381-96bd-0f8ebc94c301",
        raceID = "0ab2874d-cfdc-405e-8a97-d37bfbb23c52",
        visualID = "dc9f7e94-a634-2009-5788-775e4ef26d62"
    },
    {   index = 6, name = "Vulva_B", race = "Dwarf", visual = "DWR_M_NKD_Body_Genital_A_NoHair",
        genitalID = "065b37d7-55c7-4f6f-93a7-b76aeb366deb",
        raceID = "0ab2874d-cfdc-405e-8a97-d37bfbb23c52",
        visualID = "7d4a9298-0e8c-465f-cbb1-428fc93a5aca"
    },

    -- Elves
    {   index = 7, name = "Vulva", race = "Elf", visual = "HUM_F_NKD_Body_Genital_A_NoHair",
        genitalID = "421e9b46-07c4-4b1e-a420-046e0630b693",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "1f07d7e4-e0a1-3114-93ae-dd2f0bdfc0b0"
    },
    {   index = 8, name = "Default", race = "Elf", visual = "HUM_F_NKD_Body_Genital_A_NoHair",
        genitalID = "e1574434-42fc-474f-9d56-a63e73ef8efa",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "1f07d7e4-e0a1-3114-93ae-dd2f0bdfc0b0"
    },
    {   index = 9, name = "Vulva_B", race = "Elf", visual = "HUM_F_NKD_Body_Genital_A",
        genitalID = "702aaf5c-b569-4423-845f-e7dd38a190d7",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "302d0bf5-9e8f-fd28-ef13-b071422a7e8d"
    },
    {   index = 10, name = "Vulva_C", race = "Elf", visual = "HUM_F_NKD_Body_Genital_A_BushyHair",
        genitalID = "857ea9ad-67ad-4a09-a433-ac5cb84e052f",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "550937ce-af5d-7fd7-8fb2-928125f2d493"
    },
    {   index = 11, name = "Vulva", race = "Elf", visual = "HUM_FS_NKD_Body_Genital_A_NoHair",
        genitalID = "34eea709-27e9-40a5-a697-9c885988bf73",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "078ea8bf-18e4-4737-fb98-2a1cd7005e34"
    },
    {   index = 12, name = "Default", race = "Elf", visual = "HUM_FS_NKD_Body_Genital_A_NoHair",
        genitalID = "5440cc9c-1b1d-4e13-a209-38c883498eac",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "078ea8bf-18e4-4737-fb98-2a1cd7005e34"
    },
    {   index = 13, name = "Vulva_B", race = "Elf", visual = "HUM_FS_NKD_Body_Genital_A",
        genitalID = "7fb55ea0-73f0-4f58-be63-781ea3401411",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "98b80cc6-5727-7840-3713-08be4d4a07b7"
    },
    {   index = 14, name = "Vulva", race = "Elf", visual = "HUM_M_NKD_Body_Genital_A_NoHair",
        genitalID = "a8c205ac-e317-433e-b64d-6e31edbf8986",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "a3acdf4f-45e3-66c5-eeb3-048ee21c25cc"
    },
    {   index = 15, name = "Default", race = "Elf", visual = "HUM_M_NKD_Body_Genital_A_NoHair",
        genitalID = "d380cbc1-78d9-4627-947b-cd6f9bc79ac9",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "a3acdf4f-45e3-66c5-eeb3-048ee21c25cc"
    },
    {   index = 16, name = "Vulva_B", race = "Elf", visual = "HUM_M_NKD_Body_Genital_A",
        genitalID = "6b75332e-715a-46da-89f9-e1f05a5b5bf7",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "be414a48-0d13-9ca4-6210-7226d8bfaf15"
    },
    {   index = 17, name = "Vulva_C", race = "Elf", visual = "HUM_M_NKD_Body_Genital_A_BushyHair",
        genitalID = "e7d50ba4-651e-4457-b18f-d54f567800b1",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "eaa147e5-fe7f-74fe-75a6-efcac6f5379f"
    },
    {   index = 18, name = "Vulva", race = "Elf", visual = "HUM_MS_NKD_Body_Genital_A_NoHair",
        genitalID = "36575123-323b-4ad7-84ca-99a74f8d81bb",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "8e2b1a79-2026-157d-828c-8903f23dbd7b"
    },
    {   index = 19, name = "Default", race = "Elf", visual = "HUM_MS_NKD_Body_Genital_A_NoHair",
        genitalID = "8452425a-39d0-4f12-b18a-79d307708f53",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "8e2b1a79-2026-157d-828c-8903f23dbd7b"
    },
    {   index = 20, name = "Vulva_B", race = "Elf", visual = "HUM_MS_NKD_Body_Genital_A",
        genitalID = "3f7f1f74-deea-4669-a5a5-b39ffb099a64",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "04385805-06e7-8730-b578-497defc185c1"
    },
    {   index = 21, name = "Vulva_C", race = "Elf", visual = "HUM_MS_NKD_Body_Genital_A_BushyHair",
        genitalID = "60679d59-6fc1-4f89-8edc-bfa2980bf216",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "8fbe3573-ba17-4956-35e4-101fc465c030"
    },

    -- Drow
    {   index = 22, name = "Vulva", race = "Drow", visual = "HUM_F_NKD_Body_Genital_A_NoHair",
        genitalID = "92a7266d-98d1-4b37-8c3e-4a5a8b5e5bb8",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "1f07d7e4-e0a1-3114-93ae-dd2f0bdfc0b0"
    },
    {   index = 23, name = "Default", race = "Drow", visual = "HUM_F_NKD_Body_Genital_A_NoHair",
        genitalID = "ca208cd4-405e-492c-bf68-608c361c5db8",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "1f07d7e4-e0a1-3114-93ae-dd2f0bdfc0b0"
    },
    {   index = 24, name = "Vulva_B", race = "Drow", visual = "HUM_F_NKD_Body_Genital_A",
        genitalID = "b6f8589b-1744-49ff-8313-b8f0d13540f9",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "302d0bf5-9e8f-fd28-ef13-b071422a7e8d"
    },
    {   index = 25, name = "Vulva_C", race = "Drow", visual = "HUM_F_NKD_Body_Genital_A_BushyHair",
        genitalID = "8d5e2f02-6d70-49e4-9159-fec6bd9f26b3",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "550937ce-af5d-7fd7-8fb2-928125f2d493"
    },
    {   index = 26, name = "Vulva", race = "Drow", visual = "HUM_FS_NKD_Body_Genital_A_NoHair",
        genitalID = "9b38c212-c135-4e22-bb4e-9e577a13786a",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "078ea8bf-18e4-4737-fb98-2a1cd7005e34"
    },
    {   index = 27, name = "Default", race = "Drow", visual = "HUM_FS_NKD_Body_Genital_A_NoHair",
        genitalID = "47a9205e-7684-4dd4-a4b8-2837ac986f47",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "078ea8bf-18e4-4737-fb98-2a1cd7005e34"
    },
    {   index = 28, name = "Vulva", race = "Drow", visual = "HUM_FS_NKD_Body_Genital_A",
        genitalID = "924525e7-d02d-4d0c-9012-8d2541a1fb0b",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "98b80cc6-5727-7840-3713-08be4d4a07b7"
    },
    {   index = 29, name = "Vulva", race = "Drow", visual = "HUM_M_NKD_Body_Genital_A_NoHair",
        genitalID = "28a14235-28e4-447b-aa37-380aff752db7",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "a3acdf4f-45e3-66c5-eeb3-048ee21c25cc"
    },
    {   index = 30, name = "Default", race = "Drow", visual = "HUM_M_NKD_Body_Genital_A_NoHair",
        genitalID = "cd169886-ab2c-4756-83e4-9b3cef5fb476",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "a3acdf4f-45e3-66c5-eeb3-048ee21c25cc"
    },
    {   index = 31, name = "Vulva_B", race = "Drow", visual = "HUM_M_NKD_Body_Genital_A",
        genitalID = "31df2879-606e-4267-bf49-207724d84359",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "be414a48-0d13-9ca4-6210-7226d8bfaf15"
    },
    {   index = 32, name = "Vulva_C", race = "Drow", visual = "HUM_M_NKD_Body_Genital_A_BushyHair",
        genitalID = "f0d9aad3-1eb0-483b-92b3-f494af7c8873",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "eaa147e5-fe7f-74fe-75a6-efcac6f5379f"
    },
    {   index = 33, name = "Vulva", race = "Drow", visual = "HUM_MS_NKD_Body_Genital_A_NoHair",
        genitalID = "97640d2c-e56b-48b5-9c32-90fe5562c70d",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "8e2b1a79-2026-157d-828c-8903f23dbd7b"
    },
    {   index = 34, name = "Default", race = "Drow", visual = "HUM_MS_NKD_Body_Genital_A_NoHair",
        genitalID = "5a874437-1288-4b89-822b-611f6f8bcd8a",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "8e2b1a79-2026-157d-828c-8903f23dbd7b"
    },
    {   index = 35, name = "Vulva_B", race = "Drow", visual = "HUM_MS_NKD_Body_Genital_A",
        genitalID = "f67dfbcf-67a6-406c-a064-0902c3d3689c",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "04385805-06e7-8730-b578-497defc185c1"
    },
    {   index = 36, name = "Vulva_C", race = "Drow", visual = "HUM_MS_NKD_Body_Genital_A_BushyHair",
        genitalID = "4abf0621-2056-4e51-9b12-53fba19791bb",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "8fbe3573-ba17-4956-35e4-101fc465c030"
    },

    -- Gnomes
    {   index = 37, name = "Vulva", race = "Gnome", visual = "GNO_F_NKD_Body_Genital_A",
        genitalID = "90691650-0be0-4a36-a85c-429e3c0edac8",
        raceID = "f1b3f884-4029-4f0f-b158-1f9fe0ae5a0d",
        visualID = "6ddaa741-84e3-75e6-ddc6-abe2e7b3a871"
    },
    {   index = 38, name = "Default", race = "Gnome", visual = "GNO_F_NKD_Body_Genital_A",
        genitalID = "bbc6c487-b003-4c73-aca5-ea04f0b1c37d",
        raceID = "f1b3f884-4029-4f0f-b158-1f9fe0ae5a0d",
        visualID = "6ddaa741-84e3-75e6-ddc6-abe2e7b3a871"
    },
    {   index = 39, name = "Vulva_B", race = "Gnome", visual = "GNO_F_NKD_Body_Genital_A_NoHair",
        genitalID = "3d54ca3a-eb23-4ce8-8ecd-822e53e842fe",
        raceID = "f1b3f884-4029-4f0f-b158-1f9fe0ae5a0d",
        visualID = "40aa709c-7aca-ee05-6f33-10a515dbb19e"
    },
    {   index = 40, name = "Vulva", race = "Gnome", visual = "GNO_M_NKD_Body_Genital_A",
        genitalID = "ca011b42-5c37-4b72-85db-2ef0e6eaec40",
        raceID = "f1b3f884-4029-4f0f-b158-1f9fe0ae5a0d",
        visualID = "5bd79b62-0a52-3d03-88f2-6183ab3d0e83"
    },
    {   index = 41, name = "Default", race = "Gnome", visual = "GNO_M_NKD_Body_Genital_A",
        genitalID = "33e8878b-a61e-49c7-a30e-14a2ab0ef00f",
        raceID = "f1b3f884-4029-4f0f-b158-1f9fe0ae5a0d",
        visualID = "5bd79b62-0a52-3d03-88f2-6183ab3d0e83"
    },
    {   index = 42, name = "Vulva_B", race = "Gnome", visual = "GNO_M_NKD_Body_Genital_A_NoHair",
        genitalID = "da5a2106-3830-4c23-844a-bf875619abdf",
        raceID = "f1b3f884-4029-4f0f-b158-1f9fe0ae5a0d",
        visualID = "4adbec4e-e3a3-fdd6-d010-a9c29b133472"
    },

    -- Githyanki
    {   index = 43, name = "Vulva", race = "Githyanki", visual = "GTY_F_NKD_Body_Genital_A",
        genitalID = "0bb9adab-90e5-4013-ae98-96a092c389e9",
        raceID = "bdf9b779-002c-4077-b377-8ea7c1faa795",
        visualID = "e64e1451-aa89-1fef-3ae4-2ca7ccdeaec0"
    },
    {   index = 44, name = "Default", race = "Githyanki", visual = "GTY_F_NKD_Body_Genital_A",
        genitalID = "49a56052-5d65-4809-ae96-256eefa93582",
        raceID = "bdf9b779-002c-4077-b377-8ea7c1faa795",
        visualID = "e64e1451-aa89-1fef-3ae4-2ca7ccdeaec0"
    },
    {   index = 45, name = "Vulva_B", race = "Githyanki", visual = "GTY_F_NKD_Body_Genital_A_NoHair",
        genitalID = "89252a7e-e109-4baa-a6c7-960d16050c9c",
        raceID = "bdf9b779-002c-4077-b377-8ea7c1faa795",
        visualID = "82880fbb-57fc-82a5-6724-446352f4dc30"
    },
    {   index = 46, name = "Vulva", race = "Githyanki", visual = "GTY_M_NKD_Body_Genital_A",
        genitalID = "34c32058-3394-4808-b9ae-5305340afa8d",
        raceID = "bdf9b779-002c-4077-b377-8ea7c1faa795",
        visualID = "c3a7effc-3965-b971-cdb6-74ee23769411"
    },
    {   index = 47, name = "Default", race = "Githyanki", visual = "GTY_M_NKD_Body_Genital_A",
        genitalID = "4a56c372-1135-451b-9557-01786af9837d",
        raceID = "bdf9b779-002c-4077-b377-8ea7c1faa795",
        visualID = "c3a7effc-3965-b971-cdb6-74ee23769411"
    },
    {   index = 48, name = "Vulva_B", race = "Githyanki", visual = "GTY_M_NKD_Body_Genital_E",
        genitalID = "03d1360a-a751-4e45-83fb-0d541cc85600",
        raceID = "bdf9b779-002c-4077-b377-8ea7c1faa795",
        visualID = "006c45c1-5a82-48f8-f965-a665613f9ce6"
    },

    -- Halflings
    {   index = 49, name = "Vulva", race = "Halfling", visual = "HFL_F_NKD_Body_Genital_A",
        genitalID = "e6ec36f4-e699-45a9-bdf5-985c9082d20e",
        raceID = "78cd3bcc-1c43-4a2a-aa80-c34322c16a04",
        visualID = "6fdb0161-8c4e-2606-10aa-cff6b789d24e"
    },
    {   index = 50, name = "Default", race = "Halfling", visual = "HFL_F_NKD_Body_Genital_A",
        genitalID = "6820d864-7c5a-4259-8b45-2432d7f0974d",
        raceID = "78cd3bcc-1c43-4a2a-aa80-c34322c16a04",
        visualID = "6fdb0161-8c4e-2606-10aa-cff6b789d24e"
    },
    {   index = 51, name = "Vulva_B", race = "Halfling", visual = "HFL_F_NKD_Body_Genital_A_NoHair",
        genitalID = "7da6b60c-a6a7-48c0-babb-bb8184dd8654",
        raceID = "78cd3bcc-1c43-4a2a-aa80-c34322c16a04",
        visualID = "5c3936cf-9c04-ae4b-cc20-f19cdf437e82"
    },
    {   index = 52, name = "Vulva", race = "Halfling", visual = "HFL_M_NKD_Body_Genital_A",
        genitalID = "85afdc61-4581-43e7-90cc-78e3bbc51ac5",
        raceID = "78cd3bcc-1c43-4a2a-aa80-c34322c16a04",
        visualID = "57de58a5-7cc1-10ca-d287-bf6f03870bab"
    },
    {   index = 53, name = "Default", race = "Halfling", visual = "HFL_M_NKD_Body_Genital_A",
        genitalID = "276620bf-43f9-4da8-80f6-ce600e2064a6",
        raceID = "78cd3bcc-1c43-4a2a-aa80-c34322c16a04",
        visualID = "57de58a5-7cc1-10ca-d287-bf6f03870bab"
    },
    {   index = 54, name = "Vulva_B", race = "Halfling", visual = "HFL_M_NKD_Body_Genital_A_NoHair",
        genitalID = "650a7a6e-b386-479c-8590-1092f2b8c708",
        raceID = "78cd3bcc-1c43-4a2a-aa80-c34322c16a04",
        visualID = "b38cbf42-d792-06f2-9f5f-a08ac691fd80"
    },

    -- Half-Orcs
    {   index = 55, name = "Vulva", race = "Half_Orc", visual = "HRC_F_NKD_Body_Genital_A",
        genitalID = "38af3b00-dfc5-4fd3-981e-fddf20e4ab01",
        raceID = "5c39a726-71c8-4748-ba8d-f768b3c11a91",
        visualID = "b6333ae0-90ab-785c-582c-2e40a7dc2e1f"
    },
    {   index = 56, name = "Default", race = "Half_Orc", visual = "HRC_F_NKD_Body_Genital_A",
        genitalID = "3a5e05dc-d62a-425b-ba89-70d6977bc4fb",
        raceID = "5c39a726-71c8-4748-ba8d-f768b3c11a91",
        visualID = "b6333ae0-90ab-785c-582c-2e40a7dc2e1f"
    },
    {   index = 57, name = "Vulva_B", race = "Half_Orc", visual = "HRC_F_NKD_Body_Genital_A_NoHair",
        genitalID = "42ae3a12-98db-4994-a297-20c523796b8b",
        raceID = "5c39a726-71c8-4748-ba8d-f768b3c11a91",
        visualID = "96031c7d-7b42-e471-6401-242aaa990e5a"
    },
    {   index = 58, name = "Vulva", race = "Half_Orc", visual = "HRC_M_NKD_Body_Genital_A",
        genitalID = "46b5d44d-e296-4818-9865-708581bfd589",
        raceID = "5c39a726-71c8-4748-ba8d-f768b3c11a91",
        visualID = "b1392667-7883-8206-a2ef-207d5c3bda91"
    },
    {   index = 59, name = "Default", race = "Half_Orc", visual = "HRC_M_NKD_Body_Genital_A",
        genitalID = "b8d2d678-7fde-4c72-8651-6b244ea5efd1",
        raceID = "5c39a726-71c8-4748-ba8d-f768b3c11a91",
        visualID = "b1392667-7883-8206-a2ef-207d5c3bda91"
    },
    {   index = 60, name = "Vulva_B", race = "Half_Orc", visual = "HRC_M_NKD_Body_Genital_A_NoHair",
        genitalID = "dab5269f-6529-479f-9ff2-a59261082a1a",
        raceID = "5c39a726-71c8-4748-ba8d-f768b3c11a91",
        visualID = "de1498ff-c91e-f53c-f1b3-84b691a2d0a6"
    },

    -- Humans
    {   index = 61, name = "Vulva", race = "Human", visual = "HUM_F_NKD_Body_Genital_A",
        genitalID = "ebed5dbc-d9c8-4624-b666-07aa2ddebf4c",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "338ced1c-058d-95ec-bb6a-074d48de0d29"
    },
    {   index = 62, name = "Default", race = "Human", visual = "HUM_F_NKD_Body_Genital_A",
        genitalID = "b4153959-4066-469e-b958-821e7a83c8fd",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "338ced1c-058d-95ec-bb6a-074d48de0d29"
    },
    {   index = 63, name = "Vulva_B", race = "Human", visual = "HUM_F_NKD_Body_Genital_A_BushyHair",
        genitalID = "20062c46-c5f6-42c8-9aa5-d908bd3c131d",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "3b144037-a1fb-73de-0a77-53b2df6a8681"
    },
    {   index = 64, name = "Vulva_C", race = "Human", visual = "HUM_F_NKD_Body_Genital_A_NoHair",
        genitalID = "d404f915-0527-4af8-8929-1b212316c342",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "73b6a905-837b-2a05-4784-65f02e2432b7"
    },
    {   index = 65, name = "Vulva", race = "Human", visual = "HUM_FS_NKD_Body_Genital_A",
        genitalID = "50919ae8-864b-4193-ba0e-0ed9dfafce29",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "dbe50dbe-5bcd-6087-fb71-5992d2dce765"
    },
    {   index = 66, name = "Default", race = "Human", visual = "HUM_FS_NKD_Body_Genital_A",
        genitalID = "ed51d533-d4c4-4cf1-acbe-80afea904db3",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "dbe50dbe-5bcd-6087-fb71-5992d2dce765"
    },
    {   index = 67, name = "Vulva_B", race = "Human", visual = "HUM_FS_NKD_Body_Genital_A_NoHair",
        genitalID = "7ecad1b7-46b0-4893-a0d8-2dca7aff8f2c",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "edc51b23-74e9-fdb3-bc99-dc5a2450025a"
    },
    {   index = 68, name = "Vulva", race = "Human", visual = "HUM_M_NKD_Body_Genital_A",
        genitalID = "b590658d-9060-43d6-9c49-846052fff488",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "a1add84a-6e51-b933-4027-18e47b7a7f05"
    },
    {   index = 69, name = "Default", race = "Human", visual = "HUM_M_NKD_Body_Genital_A",
        genitalID = "d8ac2563-396f-4801-8eed-57bf92be979d",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "a1add84a-6e51-b933-4027-18e47b7a7f05"
    },
    {   index = 70, name = "Vulva_B", race = "Human", visual = "HUM_M_NKD_Body_Genital_A_BushyHair",
        genitalID = "f5e40bb4-8380-47a2-a2e3-3a7a7af4a90e",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "bd331648-cc56-a261-b649-56784feb835b"
    },
    {   index = 71, name = "Vulva", race = "Human", visual = "HUM_M_NKD_Body_Genital_A_NoHair",
        genitalID = "23df17e2-0d65-4d19-b965-93418e1e8e06",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "12369cca-598b-4d53-b949-5d34d5a3cfd6"
    },
    {   index = 72, name = "Vulva", race = "Human", visual = "HUM_MS_NKD_Body_Genital_A",
        genitalID = "bee1d89d-d76b-433e-b1a5-2890bdf8fec8",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "9a5514f0-68d5-675a-8bca-3b281004da22"
    },
    {   index = 73, name = "Default", race = "Human", visual = "HUM_MS_NKD_Body_Genital_A",
        genitalID = "23e29a10-71a1-4bbd-b8d8-1801ab51f52b",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "9a5514f0-68d5-675a-8bca-3b281004da22"
    },
    {   index = 74, name = "Vulva_B", race = "Human", visual = "HUM_MS_NKD_Body_Genital_A_BushyHair",
        genitalID = "6c66f0c4-9088-4e33-893a-fb39d10c919d",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "cf9d8104-76f1-54fc-259b-603316dc471b"
    },
    {   index = 75, name = "Vulva_C", race = "Human", visual = "HUM_MS_NKD_Body_Genital_A_NoHair",
        genitalID = "6a362b5a-956d-4954-8837-d22cf0e754d5",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "377c65af-58f8-923d-b12b-f395dbd31c3c"
    },

    -- Half-Elves
    {   index = 76, name = "Default", race = "Half_Elf", visual = "HUM_F_NKD_Body_Genital_A",
        genitalID = "27d6f236-4514-4a76-b144-ae0110c5ac2e",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "338ced1c-058d-95ec-bb6a-074d48de0d29"
    },
    {   index = 77, name = "Vulva_B", race = "Half_Elf", visual = "HUM_F_NKD_Body_Genital_A_BushyHair",
        genitalID = "e0f68e98-0de0-494f-a9cf-cbc98bdbca94",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "3b144037-a1fb-73de-0a77-53b2df6a8681"
    },
    {   index = 78, name = "Vulva_C", race = "Half_Elf", visual = "HUM_F_NKD_Body_Genital_A_NoHair",
        genitalID = "0f4ba7a4-920a-4d9c-8e20-36300faa217d",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "73b6a905-837b-2a05-4784-65f02e2432b7"
    },
    {   index = 79, name = "Vulva", race = "Half_Elf", visual = "HUM_FS_NKD_Body_Genital_A",
        genitalID = "09d38f70-ee1b-494b-bc2c-a24c3d8a9906",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "dbe50dbe-5bcd-6087-fb71-5992d2dce765"
    },
    {   index = 80, name = "Default", race = "Half_Elf", visual = "HUM_FS_NKD_Body_Genital_A",
        genitalID = "23480072-df15-4ada-a147-440dbeb03b30",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "dbe50dbe-5bcd-6087-fb71-5992d2dce765"
    },
    {   index = 81, name = "Vulva_B", race = "Half_Elf", visual = "HUM_FS_NKD_Body_Genital_A_NoHair",
        genitalID = "225caa88-6fde-4190-8eba-4b96917b2534",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "edc51b23-74e9-fdb3-bc99-dc5a2450025a"
    },
    {   index = 82, name = "Vulva", race = "Half_Elf", visual = "HUM_M_NKD_Body_Genital_A",
        genitalID = "08363d17-64dc-483c-b47d-6aebbf21e3f9",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "a1add84a-6e51-b933-4027-18e47b7a7f05"
    },
    {   index = 83, name = "Default", race = "Half_Elf", visual = "HUM_M_NKD_Body_Genital_A",
        genitalID = "3cf5af61-6ba9-49a8-b72e-89b2701eac8a",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "a1add84a-6e51-b933-4027-18e47b7a7f05"
    },
    {   index = 84, name = "Vulva_B", race = "Half_Elf", visual = "HUM_M_NKD_Body_Genital_A_BushyHair",
        genitalID = "2c09d77e-784b-426e-9f58-eb03eccade84",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "bd331648-cc56-a261-b649-56784feb835b"
    },
    {   index = 85, name = "Vulva_C", race = "Half_Elf", visual = "HUM_M_NKD_Body_Genital_A_NoHair",
        genitalID = "96dafb75-9e4f-40da-90c6-1fe76460c285",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "12369cca-598b-4d53-b949-5d34d5a3cfd6"
    },
    {   index = 86, name = "Vulva", race = "Half_Elf", visual = "HUM_MS_NKD_Body_Genital_A",
        genitalID = "a62a300f-d7f8-4af2-90d3-e1ce0f2e514d",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "9a5514f0-68d5-675a-8bca-3b281004da22"
    },
    {   index = 87, name = "Default", race = "Half_Elf", visual = "HUM_MS_NKD_Body_Genital_A",
        genitalID = "4f891ff5-595d-4786-80f8-ed29403cb76a",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "9a5514f0-68d5-675a-8bca-3b281004da22"
    },
    {   index = 88, name = "Vulva_B", race = "Half_Elf", visual = "HUM_MS_NKD_Body_Genital_A_BushyHair",
        genitalID = "706f8ace-a1cb-4e10-b93e-40f799684933",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "cf9d8104-76f1-54fc-259b-603316dc471b"
    },
    {   index = 89, name = "Vulva_C", race = "Half_Elf", visual = "HUM_MS_NKD_Body_Genital_A_NoHair",
        genitalID = "60cf4491-79c9-4c2b-a4c2-3773e76200f4",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "377c65af-58f8-923d-b12b-f395dbd31c3c"
    },

    -- Tieflings
    {   index = 90, name = "Vulva", race = "Tiefling", visual = "TIF_F_NKD_Body_Genital_A",
        genitalID = "10821adb-7ac8-4cb8-a764-47bbd2b00e4d",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "d66bd22b-7318-5f09-61f5-b147a4fdfa64"
    },
    {   index = 91, name = "Default", race = "Tiefling", visual = "TIF_F_NKD_Body_Genital_A",
        genitalID = "d7a61f14-1d65-4140-afeb-df7e7e081e9c",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "d66bd22b-7318-5f09-61f5-b147a4fdfa64"
    },
    {   index = 92, name = "Vulva_B", race = "Tiefling", visual = "TIF_F_NKD_Body_Genital_A_BushyHair",
        genitalID = "be1327c5-4091-4b4b-95da-5a8e4ad7a08c",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "9d7d38b1-4209-0e93-7faa-5bbd02a3a9ab"
    },
    {   index = 93, name = "Vulva_C", race = "Tiefling", visual = "TIF_F_NKD_Body_Genital_A_Hair",
        genitalID = "a2181bd3-1c85-4257-9c13-cf7524135850",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "53fd9d0f-e42b-7fa9-503b-6bd8c5cb7443"
    },
    {   index = 94, name = "Vulva", race = "Tiefling", visual = "TIF_FS_NKD_Body_Genital_A",
        genitalID = "479c9534-2905-4fd5-a8a9-5d8d087af777",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "ae93a5e1-f9f4-b419-9555-98a4cb6a9fcd"
    },
    {   index = 95, name = "Default", race = "Tiefling", visual = "TIF_FS_NKD_Body_Genital_A",
        genitalID = "d0e5b01d-940a-4117-b2cd-9076eff62f64",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "ae93a5e1-f9f4-b419-9555-98a4cb6a9fcd"
    },
    {   index = 96, name = "Vulva_B", race = "Tiefling", visual = "TIF_FS_NKD_Body_Genital_A_Hair",
        genitalID = "6922866c-7cba-4c2b-b806-068d8a541b19",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "ff644d43-0d62-c3a3-88ef-83cbb804dbfd"
    },
    {   index = 97, name = "Vulva", race = "Tiefling", visual = "TIF_M_NKD_Body_Genital_A",
        genitalID = "576fcd6e-0c79-4dfd-af5c-2adea2fcee6b",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "4abe40b2-d0e8-6772-a93a-a96a7c527a04"
    },
    {   index = 98, name = "Default", race = "Tiefling", visual = "",
        genitalID = "c9f25e86-004e-4317-80aa-c3996609fcf5",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "4abe40b2-d0e8-6772-a93a-a96a7c527a04"
    },
    {   index = 99, name = "Vulva_B", race = "Tiefling", visual = "TIF_M_NKD_Body_Genital_A_BushyHair",
        genitalID = "7e534da9-6e8d-43ad-9b0a-478560e67386",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "02632515-c595-8dc0-791d-2d102ea757b0"
    },
    {   index = 100, name = "Vulva_C", race = "Tiefling", visual = "TIF_M_NKD_Body_Genital_A_Hair",
        genitalID = "40647d9a-f264-42a8-8c80-9674463e9ee3",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "834fd1a9-f81a-eb58-36d1-dcf28a9be54b"
    },
    {   index = 101, name = "Vulva", race = "Tiefling", visual = "TIF_MS_NKD_Body_Genital_A",
        genitalID = "9dc231b6-9876-4c06-bcae-6d6451713f4a",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "f65adea4-56dd-6eeb-a8f4-2d08b68aa699"
    },
    {   index = 102, name = "Default", race = "Tiefling", visual = "",
        genitalID = "2f09e11a-d72e-4907-bc85-36573949ba5e",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "f65adea4-56dd-6eeb-a8f4-2d08b68aa699"
    },
    {   index = 103, name = "Vulva_B", race = "Tiefling", visual = "TIF_MS_NKD_Body_Genital_A_BushyHair",
        genitalID = "402a5db2-63e9-4ec5-b710-7f71d1f24952",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "f61a348a-6eb9-1045-3929-34dc45b84231"
    },
    {   index = 104, name = "Vulva_C", race = "Tiefling", visual = "TIF_MS_NKD_Body_Genital_A_Hair",
        genitalID = "a0e977bb-17be-4cd1-a371-0841f0c93125",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "02686c9f-98a0-6d2a-1351-c9bd50112600"
    },

    -- Dragonborn
    {   index = 105, name = "Vulva", race = "Dragonborn", visual = "DGB_M_NKD_Body_Genital_A",
        genitalID = "7c0bea36-3bca-4ef2-878a-c296c1c3d717",
        raceID = "9c61a74a-20df-4119-89c5-d996956b6c66",
        visualID = "67ef3852-f876-2b2c-0edf-4deebdc7020e"
    },
    {   index = 106, name = "Default", race = "Dragonborn", visual = "",
        genitalID = "104c06ec-3dc0-4a6f-8b05-798a5f614fa5",
        raceID = "9c61a74a-20df-4119-89c5-d996956b6c66",
        visualID = "67ef3852-f876-2b2c-0edf-4deebdc7020e"
    },
    {   index = 107, name = "Vulva", race = "Dragonborn", visual = "DGB_F_NKD_Body_Genital_A",
        genitalID = "7068217d-28ba-4b82-81c5-c77809c16a0d",
        raceID = "9c61a74a-20df-4119-89c5-d996956b6c66",
        visualID = "5327907a-36dd-7c0a-a4c5-328f4fe1e558"
    },
    {   index = 108, name = "Default", race = "Dragonborn", visual = "",
        genitalID = "f3735e8a-178c-4d00-92d7-5cf784a9ee35",
        raceID = "9c61a74a-20df-4119-89c5-d996956b6c66",
        visualID = "5327907a-36dd-7c0a-a4c5-328f4fe1e558"
    }
}
Data.BodyLibrary.PENIS = {

    -- Dwarves
    {   index = 1, name = "Penis", race = "Dwarf", visual = "DWR_F_NKD_Body_Genital_B",
        genitalID = "cab70ae2-1502-4e9a-95b2-376ced5b61a2",
        raceID = "0ab2874d-cfdc-405e-8a97-d37bfbb23c52",
        visualID = "e0339335-d083-0e5f-3408-1e8a4fbdbf2f"
    },
    {   index = 2, name = "Default", race = "Dwarf", visual = "DWR_F_NKD_Body_Genital_B",
        genitalID = "3f82015f-628e-45a1-adab-bcb30b391ec7",
        raceID = "0ab2874d-cfdc-405e-8a97-d37bfbb23c52",
        visualID = "e0339335-d083-0e5f-3408-1e8a4fbdbf2f"
    },
    {   index = 3, name = "Penis_B", race = "Dwarf", visual = "DWR_F_NKD_Body_Genital_B_NoHair",
        genitalID = "2ed7afaf-635f-48c7-b011-3d9bc820df8b",
        raceID = "0ab2874d-cfdc-405e-8a97-d37bfbb23c52",
        visualID = "ba63d562-b58f-e04a-6059-1c9b3778a044"
    },
    {   index = 4, name = "Penis_C", race = "Dwarf", visual = "DWR_F_NKD_Body_Genital_C",
        genitalID = "c79f1648-ac01-459a-a529-5d9050239bfb",
        raceID = "0ab2874d-cfdc-405e-8a97-d37bfbb23c52",
        visualID = "1b59b366-de9b-a474-e809-59d7b4fec046"
    },
    {   index = 5, name = "Penis_D", race = "Dwarf", visual = "DWR_F_NKD_Body_Genital_C_NoHair",
        genitalID = "ea5d3f98-dcb0-42c0-b8f0-8339d9389a27",
        raceID = "0ab2874d-cfdc-405e-8a97-d37bfbb23c52",
        visualID = "01c19fd4-c17a-f603-e6d8-99f4a6da2841"
    },
    {   index = 6, name = "Penis", race = "Dwarf", visual = "DWR_M_NKD_Body_Genital_B",
        genitalID = "a5905622-321d-441e-8b7b-ff03520a235d",
        raceID = "0ab2874d-cfdc-405e-8a97-d37bfbb23c52",
        visualID = "2a418650-ba7b-26a5-72b3-6a678bc833f5"
    },
    {   index = 7, name = "Default", race = "Dwarf", visual = "DWR_M_NKD_Body_Genital_B",
        genitalID = "eedd1d85-afa8-45aa-bc90-918353611602",
        raceID = "0ab2874d-cfdc-405e-8a97-d37bfbb23c52",
        visualID = "2a418650-ba7b-26a5-72b3-6a678bc833f5"
    },
    {   index = 8, name = "Penis_B", race = "Dwarf", visual = "DWR_M_NKD_Body_Genital_B_NoHair",
        genitalID = "d26fc234-5c74-4902-9ab9-a21c7aeb6ca8",
        raceID = "0ab2874d-cfdc-405e-8a97-d37bfbb23c52",
        visualID = "8bdb816b-466e-421d-331a-cad5f5403001"
    },
    {   index = 9, name = "Penis_C", race = "Dwarf", visual = "DWR_M_NKD_Body_Genital_C",
        genitalID = "77f5921c-9402-404e-b7d2-8d22368b2a39",
        raceID = "0ab2874d-cfdc-405e-8a97-d37bfbb23c52",
        visualID = "bc8cc519-e763-ad13-85c3-ec07c66a3e96"
    },
    {   index = 10, name = "Penis_D", race = "Dwarf", visual = "DWR_M_NKD_Body_Genital_C_NoHair",
        genitalID = "81504ba2-af71-4c80-b6c5-606ea5141302",
        raceID = "0ab2874d-cfdc-405e-8a97-d37bfbb23c52",
        visualID = "57ce0800-dacd-5c96-623e-e609f7f87720"
    },

    -- Elves
    {   index = 11, name = "Penis", race = "Elf", visual = "HUM_F_NKD_Body_Genital_B_NoHair",
        genitalID = "3a253675-0399-4335-9a21-c4967a1b4b61",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "0fc79afd-896c-7c4e-62d7-e19387a04681"
    },
    {   index = 12, name = "Default", race = "Elf", visual = "HUM_F_NKD_Body_Genital_B_NoHair",
        genitalID = "527be1b8-5ef9-4a8e-a74d-4569d082e0c8",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "0fc79afd-896c-7c4e-62d7-e19387a04681"
    },
    {   index = 13, name = "Penis_B", race = "Elf", visual = "HUM_F_NKD_Body_Genital_B",
        genitalID = "bc3699a9-b531-448b-ba99-51cda7be293e",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "f8741d59-68a6-26b0-9d45-2a65efbbf9b4"
    },
    {   index = 14, name = "Penis_C", race = "Elf", visual = "HUM_F_NKD_Body_Genital_B_BushyHair",
        genitalID = "71c9b8bd-21de-469f-bfdf-71e16137fe30",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "06307342-e8c4-e0f8-3956-456a357b2f18"
    },
    {   index = 15, name = "Penis_D", race = "Elf", visual = "HUM_F_NKD_Body_Genital_C",
        genitalID = "94f05a87-0ff6-4ae6-9eaf-0ee5bfa06284",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "67ae5407-e783-0e08-32bb-c621e643f8e0"
    },
    {   index = 16, name = "Penis_E", race = "Elf", visual = "HUM_F_NKD_Body_Genital_C_NoHair",
        genitalID = "fe403627-45ef-475b-930f-ee01b159354d",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "0c79945a-a8d8-a22c-b4c2-1811966815f5"
    },
    {   index = 17, name = "Penis", race = "Elf", visual = "HUM_FS_NKD_Body_Genital_B_NoHair",
        genitalID = "da9ecafa-31b8-453c-b5d9-a94e05f7968e",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "b1aa812a-1742-e24f-2475-5de2028f5e9b"
    },
    {   index = 18, name = "Default", race = "Elf", visual = "HUM_FS_NKD_Body_Genital_B_NoHair",
        genitalID = "5057ed77-a6b6-48ed-9a00-b8af9e5f4a9f",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "b1aa812a-1742-e24f-2475-5de2028f5e9b"
    },
    {   index = 19, name = "Penis_B", race = "Elf", visual = "HUM_FS_NKD_Body_Genital_B",
        genitalID = "13627ed1-10cf-403f-8428-c7065a5c3f8a",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "9f80b375-938a-e41e-c48d-04aeb016a805"
    },
    {   index = 20, name = "Penis_C", race = "Elf", visual = "HUM_FS_NKD_Body_Genital_C",
        genitalID = "a1394c3d-02ba-4f61-8167-2e67511ee97d",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "7ffa2bc6-4c6a-7e5e-afc3-95434800548e"
    },
    {   index = 21, name = "Penis_D", race = "Elf", visual = "HUM_FS_NKD_Body_Genital_C_NoHair",
        genitalID = "33eac92d-5a68-4be4-8cc7-1cb4fefb43c1",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "d14e43ea-7d90-ab45-c0a0-e24f1036a37d"
    },
    {   index = 22, name = "Penis", race = "Elf", visual = "HUM_M_NKD_Body_Genital_B_NoHair",
        genitalID = "00568ba9-a134-4fc9-a015-08879c400a8e",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "aa5de80e-ae92-33b0-b32f-0119db775761"
    },
    {   index = 23, name = "Default", race = "Elf", visual = "HUM_M_NKD_Body_Genital_B_NoHair",
        genitalID = "10f14822-bf61-4bfc-a20a-d62594adb7fd",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "aa5de80e-ae92-33b0-b32f-0119db775761"
    },
    {   index = 24, name = "Penis_B", race = "Elf", visual = "HUM_M_NKD_Body_Genital_B",
        genitalID = "2678e180-0d94-4c6d-ab81-d520b59d3f7b",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "3d7592d4-5f21-811e-b352-87549aff5243"
    },
    {   index = 25, name = "Penis_C", race = "Elf", visual = "HUM_M_NKD_Body_Genital_B_BushyHair",
        genitalID = "d5be34d5-7d8c-42a6-a57c-9237ddcae5db",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "9e2badd4-0e0e-141c-772a-5bddf9d1649b"
    },
    {   index = 26, name = "Penis_D", race = "Elf", visual = "HUM_M_NKD_Body_Genital_C",
        genitalID = "03a938e2-a9da-46be-bb44-e9744a3b8e09",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "a33971d8-a63c-6696-d2ec-d7406b5d7aa9"
    },
    {   index = 27, name = "Penis_E", race = "Elf", visual = "HUM_M_NKD_Body_Genital_C_NoHair",
        genitalID = "737e6dfb-2179-4abb-92d1-eefa358c77d9",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "678ba398-74ee-05c8-e1ac-4dd948cfea26"
    },
    {   index = 28, name = "Penis", race = "Elf", visual = "HUM_MS_NKD_Body_Genital_B_NoHair",
        genitalID = "1918f480-e7ff-4c41-b5fb-7500113ba0b0",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "d633e71b-781c-a913-81ac-562d959a4097"
    },
    {   index = 29, name = "Default", race = "Elf", visual = "HUM_MS_NKD_Body_Genital_B_NoHair",
        genitalID = "ed4ba59a-e160-4826-89b3-a9473028a462",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "d633e71b-781c-a913-81ac-562d959a4097"
    },
    {   index = 30, name = "Penis_B", race = "Elf", visual = "HUM_MS_NKD_Body_Genital_B",
        genitalID = "0863b755-66d7-492a-a03b-914bd7ff8719",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "4b1e4a53-cc55-e091-57f5-0fb89e373227"
    },
    {   index = 31, name = "Penis_C", race = "Elf", visual = "HUM_MS_NKD_Body_Genital_B_BushyHair",
        genitalID = "d02a560c-dd2b-4a2f-be8d-b0b706ddcdf0",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "09168ec5-b2be-2858-c36c-131e40f3b2cc"
    },
    {   index = 32, name = "Penis_D", race = "Elf", visual = "HUM_MS_NKD_Body_Genital_C",
        genitalID = "9ed60582-a5d1-4ea7-aee7-5afc541ebf7d",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "88563fa3-1336-cf6d-becf-32416713e9ab"
    },
    {   index = 33, name = "Penis_E", race = "Elf", visual = "HUM_MS_NKD_Body_Genital_C_NoHair",
        genitalID = "3af68ffc-c773-4dcc-83ef-3444f534281c",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "af26118c-92b0-166e-3ea4-19d202872daf"
    },

    -- Drow
    {   index = 34, name = "Penis", race = "Drow", visual = "HUM_F_NKD_Body_Genital_B_NoHair",
        genitalID = "32d77e12-6011-4669-8e69-8b4952e01e46",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "0fc79afd-896c-7c4e-62d7-e19387a04681"
    },
    {   index = 35, name = "Default", race = "Drow", visual = "HUM_F_NKD_Body_Genital_B_NoHair",
        genitalID = "1b14e748-30d2-4190-aa91-adf9e0bfc10b",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "0fc79afd-896c-7c4e-62d7-e19387a04681"
    },
    {   index = 36, name = "Penis_B", race = "Drow", visual = "HUM_F_NKD_Body_Genital_B",
        genitalID = "fcc35e32-7b77-4717-ba64-8a3c2d7000b7",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "f8741d59-68a6-26b0-9d45-2a65efbbf9b4"
    },
    {   index = 37, name = "Penis_C", race = "Drow", visual = "HUM_F_NKD_Body_Genital_B_BushyHair",
        genitalID = "9cfe5bca-3d8d-44d4-acd1-df3f1f933690",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "06307342-e8c4-e0f8-3956-456a357b2f18"
    },
    {   index = 38, name = "Penis_D", race = "Drow", visual = "HUM_F_NKD_Body_Genital_C",
        genitalID = "a82b7d66-00e8-4624-a87f-f650efdec792",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "67ae5407-e783-0e08-32bb-c621e643f8e0"
    },
    {   index = 39, name = "Penis_E", race = "Drow", visual = "HUM_F_NKD_Body_Genital_C_NoHair",
        genitalID = "394a07b5-b834-4c74-aa78-78374463788a",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "0c79945a-a8d8-a22c-b4c2-1811966815f5"
    },
    {   index = 40, name = "Penis", race = "Drow", visual = "HUM_FS_NKD_Body_Genital_B_NoHair",
        genitalID = "8784e10e-9a7f-4e34-b955-4313de002b09",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "b1aa812a-1742-e24f-2475-5de2028f5e9b"
    },
    {   index = 41, name = "Default", race = "Drow", visual = "HUM_FS_NKD_Body_Genital_B_NoHair",
        genitalID = "dce92672-9390-4974-93c4-4c1d2ed0716e",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "b1aa812a-1742-e24f-2475-5de2028f5e9b"
    },
    {   index = 42, name = "Penis_B", race = "Drow", visual = "HUM_FS_NKD_Body_Genital_B",
        genitalID = "ffa6111a-2163-4ef7-a59b-7f26fa3c882e",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "9f80b375-938a-e41e-c48d-04aeb016a805"
    },
    {   index = 43, name = "Penis_C", race = "Drow", visual = "HUM_FS_NKD_Body_Genital_C",
        genitalID = "8ff98b2f-8148-41e6-b050-8ee03b3df7a1",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "7ffa2bc6-4c6a-7e5e-afc3-95434800548e"
    },
    {   index = 44, name = "Penis_D", race = "Drow", visual = "HUM_FS_NKD_Body_Genital_C_NoHair",
        genitalID = "12ed87d1-8a57-43dc-acdd-ad18a315b5e5",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "d14e43ea-7d90-ab45-c0a0-e24f1036a37d"
    },
    {   index = 45, name = "Penis", race = "Drow", visual = "HUM_M_NKD_Body_Genital_B_NoHair",
        genitalID = "7ce29f68-bc5f-4e88-bc48-9f20f64d943f",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "aa5de80e-ae92-33b0-b32f-0119db775761"
    },
    {   index = 46, name = "Default", race = "Drow", visual = "HUM_M_NKD_Body_Genital_B_NoHair",
        genitalID = "37cace02-82b8-4c20-a5b5-0f3ab1716153",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "aa5de80e-ae92-33b0-b32f-0119db775761"
    },
    {   index = 47, name = "Penis_B", race = "Drow", visual = "HUM_M_NKD_Body_Genital_B",
        genitalID = "ad348138-6e33-48a8-8352-bb65639087c1",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "3d7592d4-5f21-811e-b352-87549aff5243"
    },
    {   index = 48, name = "Penis_C", race = "Drow", visual = "HUM_M_NKD_Body_Genital_B_BushyHair",
        genitalID = "b11451e9-f627-4923-b78b-98586cd9b120",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "9e2badd4-0e0e-141c-772a-5bddf9d1649b"
    },
    {   index = 49, name = "Penis_D", race = "Drow", visual = "HUM_M_NKD_Body_Genital_C",
        genitalID = "7bf1e4dc-62ee-4ebe-9841-f869715aeab1",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "a33971d8-a63c-6696-d2ec-d7406b5d7aa9"
    },
    {   index = 50, name = "Penis_E", race = "Drow", visual = "HUM_M_NKD_Body_Genital_C_NoHair",
        genitalID = "61667c06-299c-4b45-87d2-a194e38627ac",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "678ba398-74ee-05c8-e1ac-4dd948cfea26"
    },
    {   index = 51, name = "Penis", race = "Drow", visual = "HUM_MS_NKD_Body_Genital_B_NoHair",
        genitalID = "82a3cde3-afb2-4ed7-93ab-b6821c0bde77",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "d633e71b-781c-a913-81ac-562d959a4097"
    },
    {   index = 52, name = "Default", race = "Drow", visual = "HUM_MS_NKD_Body_Genital_B_NoHair",
        genitalID = "9c5bbb55-16fe-49e8-91c8-85db263ee6de",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "d633e71b-781c-a913-81ac-562d959a4097"
    },
    {   index = 53, name = "Penis_B", race = "Drow", visual = "HUM_MS_NKD_Body_Genital_B",
        genitalID = "c7c5be0f-cb3c-4f67-b9b7-26e3fd625ec7",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "4b1e4a53-cc55-e091-57f5-0fb89e373227"
    },
    {   index = 54, name = "Penis_C", race = "Drow", visual = "HUM_MS_NKD_Body_Genital_B_BushyHair",
        genitalID = "c7ee1aa8-5616-4461-8f51-d25ef2e544f9",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "09168ec5-b2be-2858-c36c-131e40f3b2cc"
    },
    {   index = 55, name = "Penis_D", race = "Drow", visual = "HUM_MS_NKD_Body_Genital_C",
        genitalID = "e0e799ff-ac83-4d5c-9379-c57b60639b2a",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "88563fa3-1336-cf6d-becf-32416713e9ab"
    },
    {   index = 56, name = "Penis_E", race = "Drow", visual = "HUM_MS_NKD_Body_Genital_C_NoHair",
        genitalID = "d2747199-8e72-48d4-b8aa-486df858cf67",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "af26118c-92b0-166e-3ea4-19d202872daf"
    },

    -- Gnomes
    {   index = 57, name = "Penis", race = "Gnome", visual = "GNO_F_NKD_Body_Genital_B",
        genitalID = "247db5bc-0386-4446-96f1-0200405fc94d",
        raceID = "f1b3f884-4029-4f0f-b158-1f9fe0ae5a0d",
        visualID = "05965f71-da8d-5979-78b7-f89a20f40ba2"
    },
    {   index = 58, name = "Default", race = "Gnome", visual = "GNO_F_NKD_Body_Genital_B",
        genitalID = "88bd7efc-90af-44b5-910d-c25bca87dc6c",
        raceID = "f1b3f884-4029-4f0f-b158-1f9fe0ae5a0d",
        visualID = "05965f71-da8d-5979-78b7-f89a20f40ba2"
    },
    {   index = 59, name = "Penis_B", race = "Gnome", visual = "GNO_F_NKD_Body_Genital_B_NoHair",
        genitalID = "f85af16b-d0b6-48b6-a1f8-6771acdcc779",
        raceID = "f1b3f884-4029-4f0f-b158-1f9fe0ae5a0d",
        visualID = "16815405-bb34-e617-a51c-6d6997b552e0"
    },
    {   index = 60, name = "Penis_C", race = "Gnome", visual = "GNO_F_NKD_Body_Genital_C",
        genitalID = "0a48bfa2-e013-49c8-bfee-f07e212da293",
        raceID = "f1b3f884-4029-4f0f-b158-1f9fe0ae5a0d",
        visualID = "57b36cea-3ee5-a078-639b-a1265922d664"
    },
    {   index = 61, name = "Penis_D", race = "Gnome", visual = "GNO_F_NKD_Body_Genital_C_NoHair",
        genitalID = "7980e2d5-72c4-4844-b18b-7cafef465303",
        raceID = "f1b3f884-4029-4f0f-b158-1f9fe0ae5a0d",
        visualID = "3ac72ef4-5aa7-54f9-c86d-acfb11c3302e"
    },
    {   index = 62, name = "Penis", race = "Gnome", visual = "GNO_M_NKD_Body_Genital_B",
        genitalID = "3516b686-f903-474e-9cdd-f8baf7d3d125",
        raceID = "f1b3f884-4029-4f0f-b158-1f9fe0ae5a0d",
        visualID = "6ba2d52a-bb3a-8b7d-e670-22edc796fb2a"
    },
    {   index = 63, name = "Default", race = "Gnome", visual = "GNO_M_NKD_Body_Genital_B",
        genitalID = "5f98ac85-d202-45a3-95b7-7c0875267e0b",
        raceID = "f1b3f884-4029-4f0f-b158-1f9fe0ae5a0d",
        visualID = "6ba2d52a-bb3a-8b7d-e670-22edc796fb2a"
    },
    {   index = 64, name = "Penis_B", race = "Gnome", visual = "GNO_M_NKD_Body_Genital_B_NoHair",
        genitalID = "8710ffbf-c8a8-426f-af5c-c0b1bf603451",
        raceID = "f1b3f884-4029-4f0f-b158-1f9fe0ae5a0d",
        visualID = "c30da19d-bad8-7242-dd74-0bf3555f503f"
    },
    {   index = 65, name = "Penis_C", race = "Gnome", visual = "GNO_M_NKD_Body_Genital_C",
        genitalID = "6059c226-df0b-4922-9ae5-50e104a0072c",
        raceID = "f1b3f884-4029-4f0f-b158-1f9fe0ae5a0d",
        visualID = "1d85c4d4-c52b-d5ac-80a3-ed33604c7446"
    },
    {   index = 66, name = "Penis_D", race = "Gnome", visual = "GNO_M_NKD_Body_Genital_C_NoHair",
        genitalID = "52a0aee8-e98d-4fcc-acb4-ea8dbad14961",
        raceID = "f1b3f884-4029-4f0f-b158-1f9fe0ae5a0d",
        visualID = "03b207d6-e64d-3f49-01b7-971bc6bbd7b7"
    },

    -- Githyanki
    {   index = 67, name = "Penis", race = "Githyanki", visual = "GTY_F_NKD_Body_Genital_B",
        genitalID = "b09b96f9-6a71-45cb-8bca-983bcb9ff157",
        raceID = "bdf9b779-002c-4077-b377-8ea7c1faa795",
        visualID = "20a4db7c-139f-77c9-3af1-bfda5bc2a318"
    },
    {   index = 68, name = "Default", race = "Githyanki", visual = "GTY_F_NKD_Body_Genital_B",
        genitalID = "60210a5b-bf5c-4f27-8720-369b1e1a5c5e",
        raceID = "bdf9b779-002c-4077-b377-8ea7c1faa795",
        visualID = "20a4db7c-139f-77c9-3af1-bfda5bc2a318"
    },
    {   index = 69, name = "Penis_B", race = "Githyanki", visual = "GTY_F_NKD_Body_Genital_B_NoHair",
        genitalID = "43451ee7-5387-4c26-a917-80bace98d6e5",
        raceID = "bdf9b779-002c-4077-b377-8ea7c1faa795",
        visualID = "e9b02e5e-a4c4-5ccb-5d04-57d08c3f257e"
    },
    {   index = 70, name = "Penis_C", race = "Githyanki", visual = "GTY_F_NKD_Body_Genital_C",
        genitalID = "8739c8e2-e0ee-4ed2-9ba5-65bd4e7a64b4",
        raceID = "bdf9b779-002c-4077-b377-8ea7c1faa795",
        visualID = "1b422365-a69d-5fd8-4c04-535704b0ad99"
    },
    {   index = 71, name = "Penis_D", race = "Githyanki", visual = "GTY_F_NKD_Body_Genital_C_NoHair",
        genitalID = "8a7fcf1c-60ce-4f74-9e33-19d2684a70fd",
        raceID = "bdf9b779-002c-4077-b377-8ea7c1faa795",
        visualID = "65da1853-8c2d-d134-a4c0-cc1d186cc7d1"
    },
    {   index = 72, name = "Penis", race = "Githyanki", visual = "GTY_M_NKD_Body_Genital_B",
        genitalID = "fd60b240-5c35-4da2-a4b7-7c0fb9fa5816",
        raceID = "bdf9b779-002c-4077-b377-8ea7c1faa795",
        visualID = "42c36450-8eee-51fd-4951-26f2bcd62421"
    },
    {   index = 73, name = "Default", race = "Githyanki", visual = "GTY_M_NKD_Body_Genital_B",
        genitalID = "0ffec2d6-f3a7-4720-9d16-cd90420c88cf",
        raceID = "bdf9b779-002c-4077-b377-8ea7c1faa795",
        visualID = "42c36450-8eee-51fd-4951-26f2bcd62421"
    },
    {   index = 74, name = "Penis_B", race = "Githyanki", visual = "GTY_M_NKD_Body_Genital_B_NoHair",
        genitalID = "2475b456-3dbe-48ff-af4d-fcad3656675b",
        raceID = "bdf9b779-002c-4077-b377-8ea7c1faa795",
        visualID = "791bf9f1-280e-227e-5bd4-7b9b55a38b87"
    },
    {   index = 75, name = "Penis_C", race = "Githyanki", visual = "GTY_M_NKD_Body_Genital_C",
        genitalID = "6ccb126e-c538-4b87-ae88-c413f09b5df1",
        raceID = "bdf9b779-002c-4077-b377-8ea7c1faa795",
        visualID = "d4ec9107-665e-21ec-a474-7434bda277b6"
    },
    {   index = 76, name = "Penis_D", race = "Githyanki", visual = "GTY_M_NKD_Body_Genital_C_NoHair",
        genitalID = "2f8e9781-2120-4de0-a2d7-593176a02545",
        raceID = "bdf9b779-002c-4077-b377-8ea7c1faa795",
        visualID = "16f1885d-f62a-e1c7-e9e3-ebd4fbb37523"
    },

    -- Halflings
    {   index = 77, name = "Penis", race = "Halfling", visual = "HFL_F_NKD_Body_Genital_B",
        genitalID = "4f7844ba-7745-4e26-9e18-5695e98b2fa3",
        raceID = "78cd3bcc-1c43-4a2a-aa80-c34322c16a04",
        visualID = "62131bb8-b49c-d10a-c1f8-be145d7521ad"
    },
    {   index = 78, name = "Default", race = "Halfling", visual = "HFL_F_NKD_Body_Genital_B",
        genitalID = "b489b56d-6a73-41c9-b356-f0bd4b954cc5",
        raceID = "78cd3bcc-1c43-4a2a-aa80-c34322c16a04",
        visualID = "62131bb8-b49c-d10a-c1f8-be145d7521ad"
    },
    {   index = 79, name = "Penis_B", race = "Halfling", visual = "HFL_F_NKD_Body_Genital_B_NoHair",
        genitalID = "61c512f1-a07a-45fd-91c6-9b1d58391bb6",
        raceID = "78cd3bcc-1c43-4a2a-aa80-c34322c16a04",
        visualID = "2f82a0cf-e381-6db2-d801-d74a52fa9b58"
    },
    {   index = 80, name = "Penis_C", race = "Halfling", visual = "HFL_F_NKD_Body_Genital_C",
        genitalID = "54850733-ffb1-4908-8846-6405388b2cf8",
        raceID = "78cd3bcc-1c43-4a2a-aa80-c34322c16a04",
        visualID = "fa193a38-4312-096f-0583-6b4336051e52"
    },
    {   index = 81, name = "Penis_D", race = "Halfling", visual = "HFL_F_NKD_Body_Genital_C_NoHair",
        genitalID = "1a3ad202-1be0-485c-942c-e68f4e744257",
        raceID = "78cd3bcc-1c43-4a2a-aa80-c34322c16a04",
        visualID = "3cf9e918-c3f3-5e5c-9e92-72c0765e866b"
    },
    {   index = 82, name = "Penis", race = "Halfling", visual = "HFL_M_NKD_Body_Genital_B",
        genitalID = "41c48f11-a6b2-4836-b4e2-bb33ee69c7f4",
        raceID = "78cd3bcc-1c43-4a2a-aa80-c34322c16a04",
        visualID = "6aa1d494-e8b3-ba2c-c3ab-5ff7255adff9"
    },
    {   index = 83, name = "Default", race = "Halfling", visual = "HFL_M_NKD_Body_Genital_B",
        genitalID = "77c8b015-d8f2-42ba-aae8-d94a1226ec3a",
        raceID = "78cd3bcc-1c43-4a2a-aa80-c34322c16a04",
        visualID = "6aa1d494-e8b3-ba2c-c3ab-5ff7255adff9"
    },
    {   index = 84, name = "Penis_B", race = "Halfling", visual = "HFL_M_NKD_Body_Genital_B_NoHair",
        genitalID = "a336f191-b004-46ae-8e37-68ff53fd1319",
        raceID = "78cd3bcc-1c43-4a2a-aa80-c34322c16a04",
        visualID = "fbbc3b2b-5b71-84f4-90e1-6f99fd6e3e83"
    },
    {   index = 85, name = "Penis_C", race = "Halfling", visual = "HFL_M_NKD_Body_Genital_C",
        genitalID = "451aeb50-f74c-4118-ac2c-1719c7512f63",
        raceID = "78cd3bcc-1c43-4a2a-aa80-c34322c16a04",
        visualID = "f9f28af9-1230-78cb-8bea-dce548510685"
    },
    {   index = 86, name = "Penis_D", race = "Halfling", visual = "HFL_M_NKD_Body_Genital_C_NoHair",
        genitalID = "290fcca7-2332-4d74-a3db-572fbac086e1",
        raceID = "78cd3bcc-1c43-4a2a-aa80-c34322c16a04",
        visualID = "16fe6d00-d48d-2dd0-9adf-c60f19ed7657"
    },

    -- Half-Orcs
    {   index = 87, name = "Penis", race = "Half_Orc", visual = "HRC_F_NKD_Body_Genital_B",
        genitalID = "d80f4797-aee1-4650-bfc4-dfa41431b2eb",
        raceID = "5c39a726-71c8-4748-ba8d-f768b3c11a91",
        visualID = "b7f9c4ed-b6ca-ae7e-68de-a2f5dd9d1701"
    },
    {   index = 88, name = "Default", race = "Half_Orc", visual = "HRC_F_NKD_Body_Genital_B",
        genitalID = "814e3da2-3a3b-4abc-ae77-b285d06efc90",
        raceID = "5c39a726-71c8-4748-ba8d-f768b3c11a91",
        visualID = "b7f9c4ed-b6ca-ae7e-68de-a2f5dd9d1701"
    },
    {   index = 89, name = "Penis_B", race = "Half_Orc", visual = "HRC_F_NKD_Body_Genital_B_NoHair",
        genitalID = "e011e3f5-67e4-4add-a511-05c6f82b147e",
        raceID = "5c39a726-71c8-4748-ba8d-f768b3c11a91",
        visualID = "17fbc77e-e502-2f5c-52ed-52998d61bd90"
    },
    {   index = 90, name = "Penis_C", race = "Half_Orc", visual = "HRC_F_NKD_Body_Genital_C",
        genitalID = "2f4e56e9-179e-4c77-9e01-3f0365a31178",
        raceID = "5c39a726-71c8-4748-ba8d-f768b3c11a91",
        visualID = "ae5985a3-d6ac-e50d-5a29-ec2ba8c16619"
    },
    {   index = 91, name = "Penis_D", race = "Half_Orc", visual = "HRC_F_NKD_Body_Genital_C_NoHair",
        genitalID = "71eea35d-085a-416e-9b36-b96f3c95147e",
        raceID = "5c39a726-71c8-4748-ba8d-f768b3c11a91",
        visualID = "9396107e-9b6e-d9e2-87c7-cb8ec86f7879"
    },
    {   index = 92, name = "Penis", race = "Half_Orc", visual = "HRC_M_NKD_Body_Genital_B",
        genitalID = "f806217a-707a-4188-8ac8-e01ec9f289c9",
        raceID = "5c39a726-71c8-4748-ba8d-f768b3c11a91",
        visualID = "0e396e65-5051-5e4f-390a-430299070142"
    },
    {   index = 93, name = "Default", race = "Half_Orc", visual = "HRC_M_NKD_Body_Genital_B",
        genitalID = "b22ceb0c-1673-4f3e-a24b-393169e503d5",
        raceID = "5c39a726-71c8-4748-ba8d-f768b3c11a91",
        visualID = "0e396e65-5051-5e4f-390a-430299070142"
    },
    {   index = 94, name = "Penis_B", race = "Half_Orc", visual = "HRC_M_NKD_Body_Genital_B_NoHair",
        genitalID = "565059d4-1217-49ce-8af0-d34c89fbb748",
        raceID = "5c39a726-71c8-4748-ba8d-f768b3c11a91",
        visualID = "f16de3b8-2e2d-20cf-82dc-7dbb1efc5091"
    },
    {   index = 95, name = "Penis_C", race = "Half_Orc", visual = "HRC_M_NKD_Body_Genital_C",
        genitalID = "97ab3ef3-11a6-4b1d-88d5-4de83a405edb",
        raceID = "5c39a726-71c8-4748-ba8d-f768b3c11a91",
        visualID = "ab0b3c35-d773-5512-dc09-f99655568f48"
    },
    {   index = 96, name = "Penis_D", race = "Half_Orc", visual = "HRC_M_NKD_Body_Genital_C_NoHair",
        genitalID = "79476476-624d-4c53-a1a8-64c87616ca84",
        raceID = "5c39a726-71c8-4748-ba8d-f768b3c11a91",
        visualID = "e8eb488a-f7a9-edb6-d6d2-c5070742e549"
    },

    -- Humans
    {   index = 97, name = "Penis", race = "Human", visual = "HUM_F_NKD_Body_Genital_B",
        genitalID = "5e15f15d-9600-4a77-8094-0f59d99ca42d",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "2a629211-3f5e-88bf-8001-629b17070ab7"
    },
    {   index = 98, name = "Default", race = "Human", visual = "HUM_F_NKD_Body_Genital_B",
        genitalID = "09e8639c-2b39-4795-86e7-ead609223c9c",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "2a629211-3f5e-88bf-8001-629b17070ab7"
    },
    {   index = 99, name = "Penis_B", race = "Human", visual = "HUM_F_NKD_Body_Genital_B_BushyHair",
        genitalID = "b63a265f-88b1-4184-a8b0-c0631bb66cbd",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "0febc8e5-342d-4476-44c8-eaa40734cf07"
    },
    {   index = 100, name = "Penis_C", race = "Human", visual = "HUM_F_NKD_Body_Genital_B_NoHair",
        genitalID = "e09e326a-ba0e-4d83-ba23-9c7f81d826ac",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "ea7bf6d8-f3ed-1398-32c8-b484131511fa"
    },
    {   index = 101, name = "Penis_D", race = "Human", visual = "HUM_F_NKD_Body_Genital_C",
        genitalID = "6b2b27f3-02d7-4b6a-b277-fc32fe6f0ff0",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "f4393963-532c-f19f-ac9f-e2332e68cd59"
    },
    {   index = 102, name = "Penis_E", race = "Human", visual = "HUM_F_NKD_Body_Genital_C_NoHair",
        genitalID = "e826b6c9-eb93-47d3-a96a-2386bee5680e",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "72ed8208-24ca-f565-2f34-a96128543920"
    },
    {   index = 103, name = "Penis", race = "Human", visual = "HUM_FS_NKD_Body_Genital_B",
        genitalID = "48ee875d-de58-44cd-8586-f80920f637b4",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "921745e0-8a71-187c-2a7e-9632e1ce2685"
    },
    {   index = 104, name = "Default", race = "Human", visual = "HUM_FS_NKD_Body_Genital_B",
        genitalID = "0da17e19-4ce6-4ea1-b57b-5a0e5b4917a4",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "921745e0-8a71-187c-2a7e-9632e1ce2685"
    },
    {   index = 105, name = "Penis_B", race = "Human", visual = "HUM_FS_NKD_Body_Genital_B_NoHair",
        genitalID = "52058927-df9e-42d0-a9a8-e8c5d40bfb65",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "d8af2b7c-b003-99b5-b6f9-e25a73d1fefd"
    },
    {   index = 106, name = "Penis_C", race = "Human", visual = "HUM_FS_NKD_Body_Genital_C",
        genitalID = "457b5ade-b58b-4044-a7cc-18b1e6dc0583",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "7fbe8386-ee4d-0985-b24d-114e1064b3b9"
    },
    {   index = 107, name = "Penis_D", race = "Human", visual = "HUM_FS_NKD_Body_Genital_C_NoHair",
        genitalID = "8cbb8715-f29c-4f51-a8e4-563a3ec82c97",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "f7be6845-c419-c09c-c8b3-5eb1b94b230d"
    },
    {   index = 108, name = "Penis", race = "Human", visual = "HUM_M_NKD_Body_Genital_B",
        genitalID = "2fe9e574-035b-44e7-b177-9eccdf83914e",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "6236e77f-6127-5de9-d390-72b0ed12d1fd"
    },
    {   index = 109, name = "Default", race = "Human", visual = "HUM_M_NKD_Body_Genital_B",
        genitalID = "426a0352-2d91-4e9b-94e9-d64cf4204b5c",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "6236e77f-6127-5de9-d390-72b0ed12d1fd"
    },
    {   index = 110, name = "Penis_B", race = "Human", visual = "HUM_M_NKD_Body_Genital_B_BushyHair",
        genitalID = "512fe692-3c1c-496a-b6f5-0c7b27b99fd6",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "1d43b23c-b22b-57ab-4627-a12c16c2b42f"
    },
    {   index = 111, name = "Penis_C", race = "Human", visual = "HUM_M_NKD_Body_Genital_B_NoHair",
        genitalID = "398137b8-f90a-4978-9f33-5709ff7c28be",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "441354be-b2c8-c3c5-5474-26407c139644"
    },
    {   index = 112, name = "Penis_D", race = "Human", visual = "HUM_M_NKD_Body_Genital_C",
        genitalID = "996a56da-e7f8-4647-be2f-52fa78a43439",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "245e034b-ac05-8656-c7ef-83cac38f6d91"
    },
    {   index = 113, name = "Penis_E", race = "Human", visual = "HUM_M_NKD_Body_Genital_C_NoHair",
        genitalID = "e84e1c54-ad5f-463a-a8fc-38c2854194fa",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "7441c28c-f875-d6e8-cacc-32e1e54bc615"
    },
    {   index = 114, name = "Penis", race = "Human", visual = "HUM_MS_NKD_Body_Genital_B",
        genitalID = "6f59b211-95c5-47a9-826a-f884401550b6",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "72fa164d-3c5a-e5e8-5de7-65cd9f6a1f4a"
    },
    {   index = 115, name = "Default", race = "Human", visual = "HUM_MS_NKD_Body_Genital_B",
        genitalID = "756d27d8-7fa8-4656-b56c-07eaddadcc52",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "72fa164d-3c5a-e5e8-5de7-65cd9f6a1f4a"
    },
    {   index = 116, name = "Penis_B", race = "Human", visual = "HUM_MS_NKD_Body_Genital_B_BushyHair",
        genitalID = "13ca1de1-976a-40c0-af61-6f95b0774408",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "ab534eea-b326-f69b-f136-ff7440522b6a"
    },
    {   index = 117, name = "Penis_C", race = "Human", visual = "HUM_MS_NKD_Body_Genital_B_NoHair",
        genitalID = "13d437ee-e1f1-4699-b73c-1200792c8572",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "889c1a4d-d6aa-b2b3-ab94-3f1822cd9519"
    },
    {   index = 118, name = "Penis_D", race = "Human", visual = "HUM_MS_NKD_Body_Genital_C",
        genitalID = "56fe81c9-cdbd-4af7-ae80-83d38ba7e38c",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "ab4600f0-ed82-1639-6386-0e3f2f1ae917"
    },
    {   index = 119, name = "Penis_E", race = "Human", visual = "HUM_MS_NKD_Body_Genital_C_NoHair",
        genitalID = "4739cfc3-29cc-484d-9095-8531b7ee1fcd",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "8648179b-d698-7e41-1391-26d0c811655d"
    },

    -- Half-Elves
    {   index = 120, name = "Penis", race = "Half_Elf", visual = "HUM_F_NKD_Body_Genital_B",
        genitalID = "73511e2b-7e19-4c66-a245-fde13d8d9378",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "2a629211-3f5e-88bf-8001-629b17070ab7"
    },
    {   index = 121, name = "Default", race = "Half_Elf", visual = "HUM_F_NKD_Body_Genital_B",
        genitalID = "610fb60e-eed2-4569-9061-8462a51e8e03",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "2a629211-3f5e-88bf-8001-629b17070ab7"
    },
    {   index = 122, name = "Penis_B", race = "Half_Elf", visual = "HUM_F_NKD_Body_Genital_B_BushyHair",
        genitalID = "ed17701b-99bf-4def-8422-932718783e75",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "0febc8e5-342d-4476-44c8-eaa40734cf07"
    },
    {   index = 123, name = "Penis_C", race = "Half_Elf", visual = "HUM_F_NKD_Body_Genital_B_NoHair",
        genitalID = "00746ab0-0d90-4e7a-912d-69c9a5cc7748",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "ea7bf6d8-f3ed-1398-32c8-b484131511fa"
    },
    {   index = 124, name = "Penis_D", race = "Half_Elf", visual = "HUM_F_NKD_Body_Genital_C",
        genitalID = "314cfeb7-c824-4bee-90b0-e6c2010c35a3",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "f4393963-532c-f19f-ac9f-e2332e68cd59"
    },
    {   index = 125, name = "Penis_E", race = "Half_Elf", visual = "HUM_F_NKD_Body_Genital_C_NoHair",
        genitalID = "7056bd59-77f0-45be-962a-a7af91a12214",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "72ed8208-24ca-f565-2f34-a96128543920"
    },
    {   index = 126, name = "Penis", race = "Half_Elf", visual = "HUM_FS_NKD_Body_Genital_B",
        genitalID = "c706253d-40d0-489e-b420-ac543b0cbcb1",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "921745e0-8a71-187c-2a7e-9632e1ce2685"
    },
    {   index = 127, name = "Default", race = "Half_Elf", visual = "HUM_FS_NKD_Body_Genital_B",
        genitalID = "f4ce0567-f776-47fb-80f3-d983871ee1d3",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "921745e0-8a71-187c-2a7e-9632e1ce2685"
    },
    {   index = 128, name = "Penis_B", race = "Half_Elf", visual = "HUM_FS_NKD_Body_Genital_B_NoHair",
        genitalID = "5675dfdf-60f6-4680-b516-88846622e78e",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "d8af2b7c-b003-99b5-b6f9-e25a73d1fefd"
    },
    {   index = 129, name = "Penis_C", race = "Half_Elf", visual = "HUM_FS_NKD_Body_Genital_C",
        genitalID = "4dbdfbb3-4754-4c0b-9b01-9f7f739ea142",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "7fbe8386-ee4d-0985-b24d-114e1064b3b9"
    },
    {   index = 130, name = "Penis_D", race = "Half_Elf", visual = "HUM_FS_NKD_Body_Genital_C_NoHair",
        genitalID = "40a62943-8fa7-4809-a6c9-5571eb72699d",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "f7be6845-c419-c09c-c8b3-5eb1b94b230d"
    },
    {   index = 131, name = "Penis", race = "Half_Elf", visual = "HUM_M_NKD_Body_Genital_B",
        genitalID = "2ebe0954-f771-4b72-b910-b30529d3f945",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "6236e77f-6127-5de9-d390-72b0ed12d1fd"
    },
    {   index = 132, name = "Default", race = "Half_Elf", visual = "HUM_M_NKD_Body_Genital_B",
        genitalID = "da10e842-9d01-49ef-9b83-6b457fcd0aa2",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "6236e77f-6127-5de9-d390-72b0ed12d1fd"
    },
    {   index = 133, name = "Penis_B", race = "Half_Elf", visual = "HUM_M_NKD_Body_Genital_B_BushyHair",
        genitalID = "28a97add-ec1d-430e-b3b4-ed2dec96cbb3",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "1d43b23c-b22b-57ab-4627-a12c16c2b42f"
    },
    {   index = 134, name = "Penis_C", race = "Half_Elf", visual = "HUM_M_NKD_Body_Genital_B_NoHair",
        genitalID = "b2523d70-0d12-41dc-8fe0-bd92835b4ecc",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "441354be-b2c8-c3c5-5474-26407c139644"
    },
    {   index = 135, name = "Penis_D", race = "Half_Elf", visual = "HUM_M_NKD_Body_Genital_C",
        genitalID = "257025a2-de23-426a-8f86-c05544d6f87c",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "245e034b-ac05-8656-c7ef-83cac38f6d91"
    },
    {   index = 136, name = "Penis_E", race = "Half_Elf", visual = "HUM_M_NKD_Body_Genital_C_NoHair",
        genitalID = "70a5f86c-3dd8-47b2-b731-543ebf008e2f",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "7441c28c-f875-d6e8-cacc-32e1e54bc615"
    },
    {   index = 137, name = "Penis", race = "Half_Elf", visual = "HUM_MS_NKD_Body_Genital_B",
        genitalID = "ce551aad-88f7-4558-a655-9ba3a302fd4c",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "72fa164d-3c5a-e5e8-5de7-65cd9f6a1f4a"
    },
    {   index = 138, name = "Default", race = "Half_Elf", visual = "HUM_MS_NKD_Body_Genital_B",
        genitalID = "f2f1dd00-2a68-42a3-80b9-c3962a0511d2",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "72fa164d-3c5a-e5e8-5de7-65cd9f6a1f4a"
    },
    {   index = 139, name = "Penis_B", race = "Half_Elf", visual = "HUM_MS_NKD_Body_Genital_B_BushyHair",
        genitalID = "aa11f5fd-1c0e-4b82-ad3d-20269d3bdbe3",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "ab534eea-b326-f69b-f136-ff7440522b6a"
    },
    {   index = 140, name = "Penis_C", race = "Half_Elf", visual = "HUM_MS_NKD_Body_Genital_B_NoHair",
        genitalID = "3cea6b2d-e65a-4744-9dca-dca9154c8abf",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "889c1a4d-d6aa-b2b3-ab94-3f1822cd9519"
    },
    {   index = 141, name = "Penis_D", race = "Half_Elf", visual = "HUM_MS_NKD_Body_Genital_C",
        genitalID = "edebd61c-7b16-41a0-9167-0ed5b40d1ba1",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "ab4600f0-ed82-1639-6386-0e3f2f1ae917"
    },
    {   index = 142, name = "Penis_E", race = "Half_Elf", visual = "HUM_MS_NKD_Body_Genital_C_NoHair",
        genitalID = "cea49f40-28d3-4074-aed6-23bab3cb2961",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "8648179b-d698-7e41-1391-26d0c811655d"
    },

    -- Tieflings
    {   index = 143, name = "Penis", race = "Tiefling", visual = "TIF_F_NKD_Body_Genital_B_NoHair",
        genitalID = "c1573be8-d83e-49fe-b628-1878d02b83c4",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "34d1075f-2478-5f6b-3652-22be3a32cf7d"
    },
    {   index = 144, name = "Default", race = "Tiefling", visual = "TIF_F_NKD_Body_Genital_B_NoHair",
        genitalID = "dc7cf0e7-4d99-47b3-af2d-7f8dc33c126b",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "34d1075f-2478-5f6b-3652-22be3a32cf7d"
    },
    {   index = 145, name = "Penis_B", race = "Tiefling", visual = "TIF_F_NKD_Body_Genital_B",
        genitalID = "6676a9f0-0ab5-44d2-8d4d-1f2e8b885498",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "141f20fa-b938-98c8-817b-779facf73b57"
    },
    {   index = 146, name = "Penis_C", race = "Tiefling", visual = "TIF_F_NKD_Body_Genital_C",
        genitalID = "b32d6bb5-6a19-45ef-add2-11283321b7a1",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "8ebf98a0-1f48-4373-185d-3ca86ac8bd45"
    },
    {   index = 147, name = "Penis_D", race = "Tiefling", visual = "TIF_F_NKD_Body_Genital_C_NoHair",
        genitalID = "29bb84a6-8360-4504-88b6-023ddcafa7db",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "ce084b86-6248-d195-d15e-4c315240f575"
    },
    {   index = 148, name = "Penis", race = "Tiefling", visual = "TIF_FS_NKD_Body_Genital_B_NoHair",
        genitalID = "13114b3e-713b-4871-ab86-8d25b1271cef",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "c74f6dda-afe8-e137-a7ae-e17a706703ba"
    },
    {   index = 149, name = "Default", race = "Tiefling", visual = "TIF_FS_NKD_Body_Genital_B_NoHair",
        genitalID = "5893db07-dd6d-4add-81de-43b797231a0e",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "c74f6dda-afe8-e137-a7ae-e17a706703ba"
    },
    {   index = 150, name = "Penis_B", race = "Tiefling", visual = "TIF_FS_NKD_Body_Genital_B",
        genitalID = "f122c186-3a3e-4a9e-b116-ef0c28344b89",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "878039f9-63a9-f9c8-633c-a5abb7be6090"
    },
    {   index = 151, name = "Penis_C", race = "Tiefling", visual = "TIF_FS_NKD_Body_Genital_C",
        genitalID = "ac260ecb-0571-447c-bfe8-d5084813b101",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "3d208bff-a2ac-1314-cd92-591563db9e70"
    },
    {   index = 152, name = "Penis", race = "Tiefling", visual = "TIF_M_NKD_Body_Genital_B_NoHair",
        genitalID = "8156f035-8f12-406e-9174-3c5e0f890696",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "35d1d860-d38c-d995-0b1b-16d04728e341"
    },
    {   index = 153, name = "Default", race = "Tiefling", visual = "TIF_M_NKD_Body_Genital_B_NoHair",
        genitalID = "f42c550b-0322-4e3e-9155-4342c438103b",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "35d1d860-d38c-d995-0b1b-16d04728e341"
    },
    {   index = 154, name = "Penis_B", race = "Tiefling", visual = "TIF_M_NKD_Body_Genital_B",
        genitalID = "1e4aa916-cfe7-4280-aac3-e8891b46a457",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "c3cddd15-a2ee-4268-9d4f-c1e7674879b3"
    },
    {   index = 155, name = "Penis_C", race = "Tiefling", visual = "TIF_M_NKD_Body_Genital_C_BushyHair",
        genitalID = "1b3e8b7c-365e-48e4-9ea6-07565e2bd9d9",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "614f5dbc-81e2-47b8-42be-7cbed08c8e26"
    },
    {   index = 156, name = "Penis_D", race = "Tiefling", visual = "TIF_M_NKD_Body_Genital_C_NoHair",
        genitalID = "bfe6c250-68c4-4985-92f3-7807ccb8d35a",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "5ca86e95-b289-6641-76df-edc902baf9a5"
    },
    {   index = 157, name = "Penis", race = "Tiefling", visual = "TIF_MS_NKD_Body_Genital_B",
        genitalID = "db17497d-3d9a-4150-8b5b-3d238553a432",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "b2ab50ba-93bb-1107-ee57-cff286d2687a"
    },
    {   index = 158, name = "Default", race = "Tiefling", visual = "TIF_MS_NKD_Body_Genital_B",
        genitalID = "1f922d58-06e4-41c7-947b-39b656ea1671",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "b2ab50ba-93bb-1107-ee57-cff286d2687a"
    },
    {   index = 159, name = "Penis_B", race = "Tiefling", visual = "TIF_MS_NKD_Body_Genital_C",
        genitalID = "6cc4bb64-07b1-4c9a-ba8d-1c1e3069de94",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "f0bb716d-d6b5-d496-cb3f-7ff68dc55cf3"
    },
    {   index = 160, name = "Penis_C", race = "Tiefling", visual = "TIF_MS_NKD_Body_Genital_C_BushyHair",
        genitalID = "40cae433-5db0-47be-a068-50a996424e3e",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "8310e4da-6f03-a981-86a2-60273755d52b"
    },
    {   index = 161, name = "Penis_D", race = "Tiefling", visual = "TIF_MS_NKD_Body_Genital_C_NoHair",
        genitalID = "66bb2f27-a505-4ebc-9eb8-0aa365ec862f",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "245e173f-4fda-26cb-77cc-99a59a74be2e"
    },

    --Dragonborn
    {   index = 162, name = "Penis", race = "Dragonborn", visual = "DGB_M_NKD_Body_Genital_B",
        genitalID = "b2871277-8cd3-4e28-82c1-70cacdda2815",
        raceID = "9c61a74a-20df-4119-89c5-d996956b6c66",
        visualID = "38bb9ec3-f5d3-18a5-4484-007ecccabc8e"
    },
    {   index = 163, name = "Default", race = "Dragonborn", visual = "DGB_M_NKD_Body_Genital_B",
        genitalID = "e5b9ae92-3e18-4a7b-820c-6e3a6d1655d2",
        raceID = "9c61a74a-20df-4119-89c5-d996956b6c66",
        visualID = "38bb9ec3-f5d3-18a5-4484-007ecccabc8e"
    },
    {   index = 164, name = "Penis", race = "Dragonborn", visual = "DGB_F_NKD_Body_Genital_B",
        genitalID = "e353b86b-db05-4cfc-9142-0395cefea52c",
        raceID = "9c61a74a-20df-4119-89c5-d996956b6c66",
        visualID = "61f59a7e-ced5-ee43-86af-a8a87deefcad"
    },
    {   index = 165, name = "Default", race = "Dragonborn", visual = "DGB_F_NKD_Body_Genital_B",
        genitalID = "5c70068f-6503-44e1-81e3-10494d46fcb9",
        raceID = "9c61a74a-20df-4119-89c5-d996956b6c66",
        visualID = "61f59a7e-ced5-ee43-86af-a8a87deefcad"
    }
}

---------------------------------------------------------------------------------------------------------

--                                        MrFunSize Erections

---------------------------------------------------------------------------------------------------------

Data.BodyLibrary.FunErections = {

    -- Dwarves
    {   index = 1, name = "Erect", race = "Dwarf", visual = "DWR_F_Erect",
        genitalID = "c1d4ead2-7e4c-4b52-a42e-e3c0f60dd913",
        raceID = "0ab2874d-cfdc-405e-8a97-d37bfbb23c52",
        visualID = "d20a9468-2a47-48c5-b9d9-c65d34442115"
    },
    {   index = 2, name = "Hairy Erect", race = "Dwarf", visual = "DWR_F_Hairy_Erect",
        genitalID = "661a538b-c01b-4ba4-a01c-5ac5fd5b4e70",
        raceID = "0ab2874d-cfdc-405e-8a97-d37bfbb23c52",
        visualID = "58327c1b-250d-4257-a4eb-df5d483f03eb"
    },
    {   index = 3, name = "Erect", race = "Dwarf", visual = "DWR_M_Erect",
        genitalID = "428cbaa8-3546-4789-bc15-6cb4d62f2d63",
        raceID = "0ab2874d-cfdc-405e-8a97-d37bfbb23c52",
        visualID = "5cefcbb0-66d5-4847-b02a-8ac792319f57"
    },
    {   index = 4, name = "Hairy Erect", race = "Dwarf", visual = "DWR_M_Hairy_Erect",
        genitalID = "cf220afd-496e-401c-8dab-f5716f3a49f0",
        raceID = "0ab2874d-cfdc-405e-8a97-d37bfbb23c52",
        visualID = "ab93d695-a60a-40e0-a765-2d93cd194e63"
    },

    -- Elves
    {   index = 5, name = "Erect", race = "Elf", visual = "DWR_F_Erect",
        genitalID = "38e7bb58-27fa-48be-97dc-8ee5625a385d",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "6083b52b-db30-48f0-8246-268e27810613"
    },
    {   index = 6, name = "Erect", race = "Elf", visual = "DWR_FS_Erect",
        genitalID = "d8172b73-6d5f-43d7-8423-7e3b130e0527",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "f0b47c1c-cb52-44b4-aae5-5c65622948ce"
    },
    {   index = 7, name = "Erect", race = "Elf", visual = "DWR_M_Erect",
        genitalID = "4bd0c847-a2b9-49fb-b7cd-b439cb22a3c1",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "947dbb2e-ba7e-4b24-a359-772a19770df6"
    },
    {   index = 8, name = "Erect", race = "Elf", visual = "DWR_MS_Erect",
        genitalID = "df9a5499-504a-4822-90bf-40e46d1a058d",
        raceID = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a",
        visualID = "dd51a3b8-0f0b-42ef-a3fa-f5909f25572f"
    },

    -- Drow
    {   index = 9, name = "Erect", race = "Drow", visual = "DRW_F_Erect",
        genitalID = "d685f0b9-54b0-4aa2-a1c9-07de00cc2808",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "6083b52b-db30-48f0-8246-268e27810613"
    },
    {   index = 10, name = "Erect", race = "Drow", visual = "DRW_FS_Erect",
        genitalID = "6f923f44-2e89-41e4-8ccb-13890cdb6db4",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "f0b47c1c-cb52-44b4-aae5-5c65622948ce"
    },
    {   index = 11, name = "Erect", race = "Drow", visual = "DRW_M_Erect",
        genitalID = "505b9a2a-f673-475b-823e-dd09fd334a8d",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "947dbb2e-ba7e-4b24-a359-772a19770df6"
    },
    {   index = 12, name = "Erect", race = "Drow", visual = "DRW_MS_Erect",
        genitalID = "f8715972-6e0f-46bf-ac3b-ee6e5d4b0c0a",
        raceID = "4f5d1434-5175-4fa9-b7dc-ab24fba37929",
        visualID = "dd51a3b8-0f0b-42ef-a3fa-f5909f25572f"
    },

    -- Gnomes
    {   index = 13, name = "Erect", race = "Gnome", visual = "GNO_F_Erect",
        genitalID = "63203eda-c550-47f5-8d4a-52455f50a860",
        raceID = "f1b3f884-4029-4f0f-b158-1f9fe0ae5a0d",
        visualID = "27048a8c-25d1-4f5b-a247-1d8442dd1c53"
    },
    {   index = 14, name = "Hairy Erect", race = "Gnome", visual = "GNO_F_Hairy_Erect",
        genitalID = "c2d870c4-4ddf-43e1-8a57-914120c85985",
        raceID = "f1b3f884-4029-4f0f-b158-1f9fe0ae5a0d",
        visualID = "17463836-9501-49c5-9377-98a417fbe967"
    },
    {   index = 15, name = "Erect", race = "Gnome", visual = "GNO_M_Erect",
        genitalID = "83c2b026-6314-4a58-88f2-318f4e82d954",
        raceID = "f1b3f884-4029-4f0f-b158-1f9fe0ae5a0d",
        visualID = "d2ab77ca-63ec-4b75-a72a-417ac98fecd6"
    },
    {   index = 16, name = "Hairy Erect", race = "Gnome", visual = "GNO_M_Hairy_Erect",
        genitalID = "ce451147-0023-4cee-b526-080a8b94c01b",
        raceID = "f1b3f884-4029-4f0f-b158-1f9fe0ae5a0d",
        visualID = "32775b67-220b-4872-b73e-eb5453c69f12"
    },

    -- Githyanki
    {   index = 17, name = "Erect", race = "Githyanki", visual = "GTY_F_Erect",
        genitalID = "8d80cf10-2b4c-4be2-8a3c-2c64c2a09546",
        raceID = "bdf9b779-002c-4077-b377-8ea7c1faa795",
        visualID = "61a5f54e-238e-48eb-ba86-72642972c6c7"
    },
    {   index = 18, name = "Hairy Erect", race = "Githyanki", visual = "GTY_F_Hairy_Erect",
        genitalID = "bb8f199e-6d7f-4db8-938d-0be9e375fda7",
        raceID = "bdf9b779-002c-4077-b377-8ea7c1faa795",
        visualID = "225b5184-bc78-412b-8f0b-30bd7624311f"
    },
    {   index = 19, name = "Erect", race = "Githyanki", visual = "GTY_M_Erect",
        genitalID = "afddee7a-7178-449b-a297-933ff5e8a236",
        raceID = "bdf9b779-002c-4077-b377-8ea7c1faa795",
        visualID = "0ec5d550-afe5-4f8f-ab36-f1282c7529e1"
    },
    {   index = 20, name = "Hairy Erect", race = "Githyanki", visual = "GTY_M_Hairy_Erect",
        genitalID = "984b242e-2413-4b12-9cc8-848303dda089",
        raceID = "bdf9b779-002c-4077-b377-8ea7c1faa795",
        visualID = "0718f8d8-3ec3-465b-b528-b4fed59e7b87"
    },

    -- Halflings
    {   index = 21, name = "Erect", race = "Halfling", visual = "HFL_F_Erect",
        genitalID = "d4a4cd06-5a26-4933-856c-ced1c789b170",
        raceID = "78cd3bcc-1c43-4a2a-aa80-c34322c16a04",
        visualID = "03567bfe-6b27-4138-8a8c-5f3f922759e5"
    },
    {   index = 22, name = "Hairy Erect", race = "Halfling", visual = "HFL_F_Hairy_Erect",
        genitalID = "4937ebec-ce4e-4500-b6e0-46c8be705f74",
        raceID = "78cd3bcc-1c43-4a2a-aa80-c34322c16a04",
        visualID = "600f5737-3420-4cea-bfac-ec5243851ab3"
    },
    {   index = 23, name = "Erect", race = "Halfling", visual = "HFL_M_Erect",
        genitalID = "138e251e-3576-4cef-b076-7d22313ba1a7",
        raceID = "78cd3bcc-1c43-4a2a-aa80-c34322c16a04",
        visualID = "7811d53b-b997-4889-bca5-7c501c2d6a4d"
    },
    {   index = 24, name = "Hairy Erect", race = "Halfling", visual = "HFL_M_Hairy_Erect",
        genitalID = "0365f7f4-0143-4683-a0b0-e5bdf27b65d0",
        raceID = "78cd3bcc-1c43-4a2a-aa80-c34322c16a04",
        visualID = "667ea820-e84c-4410-9a54-89e9a0c79d95"
    },

    -- Half-Orcs
    {   index = 25, name = "Erect", race = "Half-Orc", visual = "HRC_F_Erect",
        genitalID = "de21ebff-cade-40b5-b490-a5e426ca9a0d",
        raceID = "5c39a726-71c8-4748-ba8d-f768b3c11a91",
        visualID = "f59535e7-85a8-4009-be6d-1dcb118686a9"
    },
    {   index = 26, name = "Hairy Erect", race = "Half-Orc", visual = "HRC_F_Hairy_Erect",
        genitalID = "64008bde-9f18-4cab-abea-e794edb2324c",
        raceID = "5c39a726-71c8-4748-ba8d-f768b3c11a91",
        visualID = "67f40cbc-7921-464f-ad01-3e4c30a49d6e"
    },
    {   index = 27, name = "Erect", race = "Half-Orc", visual = "HRC_M_Erect",
        genitalID = "6344de9d-1bf6-49e9-bd90-c5db11091dbe",
        raceID = "5c39a726-71c8-4748-ba8d-f768b3c11a91",
        visualID = "547b6e81-b1bb-46fc-a7e5-1966dcc41bbd"
    },
    {   index = 28, name = "Hairy Erect", race = "Half-Orc", visual = "HRC_M_Hairy_Erect",
        genitalID = "28a52e54-5653-4c01-b713-1f0f1457e778",
        raceID = "5c39a726-71c8-4748-ba8d-f768b3c11a91",
        visualID = "2135e5b4-a64f-4c16-9674-bcbf02158643"
    },

    -- Human
    {   index = 29, name = "Erect", race = "Human", visual = "HUM_F_Erect",
        genitalID = "b50f6bea-ca4a-42d2-9f0f-58855be570df",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "13ff0e60-69b6-444e-8b38-2d34cfff06f3"
    },
    {   index = 30, name = "Hairy Erect", race = "Human", visual = "HUM_F_Hairy_Erect",
        genitalID = "af7952b7-9405-49a1-b0f9-5e8864a926b1",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "437a4487-ef4a-4771-b62b-1eff41977ac6"
    },
    {   index = 31, name = "Erect", race = "Human", visual = "HUM_FS_Erect",
        genitalID = "df64c112-0eb3-4d27-9367-df88959e907f",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "18064e63-f226-4b1a-b76c-7255f82da234"
    },
    {   index = 32, name = "Hairy Erect", race = "Human", visual = "HUM_FS_Hairy_Erect",
        genitalID = "6aae16ff-0cfc-4baf-843f-74bb7bd92b4c",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "5fb024ae-61dc-4bd1-a38b-45246ba9c408"
    },
    {   index = 33, name = "Erect", race = "Human", visual = "HUM_M_Erect",
        genitalID = "beb19008-1fee-4abb-a15d-5c89247e751a",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "58607abf-b2c0-460b-9ec8-2af178b9d263"
    },
    {   index = 34, name = "Hairy Erect", race = "Human", visual = "HUM_M_Hairy_Erect",
        genitalID = "8d84422a-a9a6-4801-96c4-f7d94ac6ff01",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "7bd9c112-8507-4d6a-a36a-7c62350dc73d"
    },
    {   index = 35, name = "Erect", race = "Human", visual = "HUM_MS_Erect",
        genitalID = "77880485-52d7-4c7e-a972-e38a9cfc28d7",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "b3e1e3c7-7c75-4945-be0e-454499276b88"
    },
    {   index = 36, name = "Hairy Erect", race = "Human", visual = "HUM_MS_Hairy_Erect",
        genitalID = "ad524dee-b817-4f7c-bd3e-80900bc14240",
        raceID = "0eb594cb-8820-4be6-a58d-8be7a1a98fba",
        visualID = "f6ec1a50-4b10-4d93-b17d-b3593ab2762e"
    },

    -- Half-Elves
    {   index = 37, name = "Erect", race = "Half-Elf", visual = "HEL_F_Erect",
        genitalID = "4eac75b6-7271-4b28-aadd-0e322ea5391b",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "13ff0e60-69b6-444e-8b38-2d34cfff06f3"
    },
    {   index = 38, name = "Hairy Erect", race = "Half-Elf", visual = "HEL_F_Hairy_Erect",
        genitalID = "a9253cba-e3bb-4b74-91b2-50d08c7354f4",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "437a4487-ef4a-4771-b62b-1eff41977ac6"
    },
    {   index = 39, name = "Erect", race = "Half-Elf", visual = "HEL_FS_Erect",
        genitalID = "c7591733-9a79-4f4a-a775-0bae6f129c5c",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "18064e63-f226-4b1a-b76c-7255f82da234"
    },
    {   index = 40, name = "Hairy Erect", race = "Half-Elf", visual = "HEL_FS_Hairy_Erect",
        genitalID = "0583a5ea-99f3-47a7-bf7b-e0ac8e04a390",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "5fb024ae-61dc-4bd1-a38b-45246ba9c408"
    },
    {   index = 41, name = "Erect", race = "Half-Elf", visual = "HEL_M_Erect",
        genitalID = "83b2f999-5e8e-49d9-a42c-191eac5e3e89",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "58607abf-b2c0-460b-9ec8-2af178b9d263"
    },
    {   index = 42, name = "Hairy Erect", race = "Half-Elf", visual = "HEL_M_Hairy_Erect",
        genitalID = "8b164b83-f3b7-44df-99d4-f375c181aa6c",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "7bd9c112-8507-4d6a-a36a-7c62350dc73d"
    },
    {   index = 43, name = "Erect", race = "Half-Elf", visual = "HEL_MS_Erect",
        genitalID = "14ba64b2-fdac-47a9-beac-b408360f2244",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "b3e1e3c7-7c75-4945-be0e-454499276b88"
    },
    {   index = 44, name = "Hairy Erect", race = "Half-Elf", visual = "HEL_MS_Hairy_Erect",
        genitalID = "9bf57322-616d-43b7-a9e9-8393fe9bd12f",
        raceID = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0",
        visualID = "f6ec1a50-4b10-4d93-b17d-b3593ab2762e"
    },

    -- Tieflings
    {   index = 45, name = "Erect", race = "Tiefling", visual = "TIF_F_Erect",
        genitalID = "b4a9b624-f2e0-4382-bb09-0388a97f2366",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "5befe221-41b2-4db5-a816-a68516e455e9"
    },
    {   index = 46, name = "Hairy Erect", race = "Half-Elf", visual = "TIF_F_Hairy_Erect",
        genitalID = "fd4c161a-c267-4b67-86f8-014532f55e56",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "c17513df-8093-41f8-9f05-f6f3e0bb6dfb"
    },
    {   index = 47, name = "Erect", race = "Half-Elf", visual = "TIF_FS_Erect",
        genitalID = "c92b5626-bdbf-4498-8759-6404b223191d",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "d1427cf9-470f-4199-bdf2-f9efbb75cbb9"
    },
    {   index = 48, name = "Hairy Erect", race = "Half-Elf", visual = "TIF_FS_Hairy_Erect",
        genitalID = "306fb48f-9563-4161-a4aa-018a2b1011ac",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "26dcfea5-3a3d-4f0b-820e-94bcd98f0f1c"
    },
    {   index = 49, name = "Erect", race = "Half-Elf", visual = "TIF_M_Erect",
        genitalID = "8ebab11f-e8d9-42d3-a110-2dcaf4bbef3c",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "cded95c0-30c6-4412-a528-26932fa9516b"
    },
    {   index = 50, name = "Hairy Erect", race = "Half-Elf", visual = "TIF_M_Hairy_Erect",
        genitalID = "59e10a67-97ec-4039-a2a8-612d3c8ea24a",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "99186a62-f8c4-4a5c-9f08-2525c128f18b"
    },
    {   index = 51, name = "Erect", race = "Half-Elf", visual = "TIF_MS_Erect",
        genitalID = "2e3ad1fa-2881-4bc9-8c7a-56f47d83be16",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "95a6bb67-e057-4b89-9e12-c7bbaf094abc"
    },
    {   index = 52, name = "Hairy Erect", race = "Half-Elf", visual = "TIF_MS_Hairy_Erect",
        genitalID = "bb920a89-a1ac-46eb-8d2e-4aee8a1d60ff",
        raceID = "b6dccbed-30f3-424b-a181-c4540cf38197",
        visualID = "6513f718-7b57-4120-b1e8-5c0ed0212104"
    },

    --Dragonborn
    {   index = 53, name = "Erect", race = "Dragonborn", visual = "DGB_M_Erect_Genital_B",
        genitalID = "34016c0c-36d3-4696-9c28-9398936a3c1a",
        raceID = "9c61a74a-20df-4119-89c5-d996956b6c66",
        visualID = "0a271d44-cddf-47de-8b02-2edf8753b3f3"
    },
    {   index = 54, name = "Erect", race = "Dragonborn", visual = "DGB_F_Erect_Genital_B",
        genitalID = "02e09af7-eb15-4e40-99f6-4575b4b7defd",
        raceID = "9c61a74a-20df-4119-89c5-d996956b6c66",
        visualID = "274508c8-30ee-43f4-964f-6a264fae13c2"
    },
}