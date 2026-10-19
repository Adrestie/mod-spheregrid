--[[
    This file is part of mod-spheregrid.

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
    Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program. If not, see <http://www.gnu.org/licenses/>.
]]

--[[----------------------------------------------------------------------------
    Sphere grid -- the Progression window, client side (shipped by AIO)

    The window the WoW-mods modules share when ForeverUI is on the client:
    each module brings the same code, the first one loaded creates the window
    (global Progression), every module adds its tab. Player_Client.lua adds
    the sphere grid's.

    What follows, from DÉBUT to FIN, is the common copy, kept byte for byte
    identical to the one in Attriboost_Client.lua (mod-attriboost),
    ItemUpgrade_Client.lua (mod-item-upgrade) and Tarot_Client.lua
    (mod-stellar-tarot): a change there is carried here, and the other way
    round.
------------------------------------------------------------------------------]]

local AIO = AIO or require("AIO")

if AIO.AddAddon() then
    return                                  -- server side: we stop here
end

-- DÉBUT DE LA FENÊTRE PROGRESSION -- copie commune, IDENTIQUE dans
-- Attriboost_Client.lua, ItemUpgrade_Client.lua et Tarot_Client.lua
-- (mod-stellar-tarot) : toute modification se reporte dans les autres.
-- ---------------------------------------------------------------------------
-- Une fenêtre au thème de Camelot -- le LegacySystemFrame de camelot -- dont
-- les modules du serveur ajoutent les onglets (demande du 2026-09-29 : « si
-- le serveur a le module d'interface de mod-forever-ui d'installé, au lieu
-- d'avoir des boutons autour de la minimap et une interface grise, il faut un
-- bouton dans la barre des micro boutons. cliquer sur le bouton devra ouvrir
-- une fenêtre au thème de Camelot avec un onglet pour "Attriboost" et un
-- autre pour item upgrade (sachant que l'un ou l'autre peut être absent) » ;
-- l'icône : celle du menu Legacy de camelot ; le nom : Progression).
--
-- PORTÉE PAR LES MODULES (choix de l'utilisateur, 2026-09-29) : ce code
-- arrive avec chaque module, par AIO. Le premier module chargé crée la
-- fenêtre ; le suivant la trouve (global Progression) et n'y ajoute que son
-- onglet.
--
-- INDÉPENDANTE DE ForeverUI (règle de l'utilisateur, 2026-09-29 : les
-- modules « détectent si "forever-ui" est installé. Si non -> addon normaux,
-- si oui, ils montent leurs ui chacun avec les sources que "forever-ui" a
-- installé et qu'il lui dise "ajoute ce bouton dans ta micro barre" »).
-- ForeverUI ne connaît ni cette fenêtre ni ces modules, et ce code n'appelle
-- AUCUNE de ses fonctions de dessin : tout ce qui se dessine est écrit ici ou
-- dans la page du module. De ForeverUI, il ne prend que :
--   * ses FICHIERS de textures installés (Interface\ForeverUI\...), avec
--     leurs coordonnées recopiées dans les tables ci-dessous et dans celles
--     des pages ;
--   * sa micro-barre : ForeverUI.AddMicroButton (le bouton, avec le jeu
--     d'icônes « legacy » de ForeverUI) et ForeverUI.UpdateMicro (enfoncé tant
--     que la fenêtre est ouverte).
--   * sa barre d'action, s'il l'a : ForeverUI.TabMacros, pour poser un
--     onglet sur une barre (2026-10-19).
-- Sans ForeverUI.AddMicroButton, la fenêtre n'existe pas, et les modules
-- gardent leur interface d'origine.
--
-- RELEVÉ -- CAMELOT (blizzard_legacysystem : blizzard_legacysystem.xml /
-- .lua, blizzard_legacysystemtemplates.xml, _bootstrap.lua, _registration
-- .lua ; blizzard_micromenu : mainline/mainmenubarmicrobuttons.lua,
-- camelot/micromenucontaineroverrides.lua ; blizzard_sharedxml :
-- mainline/shareduipaneltemplates.xml, portraitframe.lua,
-- shared/button/threeslicebuttontemplate.xml / .lua) :
--   fenêtre      LegacySystemFrame, PortraitFrameTemplate, 920 x 575 ;
--                RegisterUIPanel : area "left", xoffset 35, pushable 1,
--                largeur 1005 ; ToggleFrame ; sons IG_CHARACTER_INFO_OPEN /
--                _CLOSE ; pas de titre
--   cadre        roche UI-Background-Rock en mosaïque de (2, -21) à
--                (-2, 2) ; stries _UI-Frame-TopTileStreaks de 43 à
--                (6, -21) ; coins du métal à (-13, 16), (2, 16), (-13, -8),
--                (2, -8), bords tendus entre eux ; bandeau du titre de
--                (58, -1) à (-24, -1), 20 de haut, texte GameFontNormal
--                à -5 de son haut
--   croix        UIPanelCloseButton : 24 x 24, RedButton-Exit / -pressed /
--                -disabled, lueur RedButton-Highlight en ADD, à TOPRIGHT
--                (-2, 1) de la fenêtre
--   portrait     SetPortraitAtlasRaw("Legacy-up-c60"), 45 x 62, TOPLEFT
--                (2, 10) ; le CircleMask du gabarit (TempPortraitAlphaMask)
--                le suit de (2, 0) à (-2, 4) ; le portrait (niveau 400)
--                passe sous le métal (500)
--   onglets      LegacySystemTabTemplate (LargeSideTabButtonTemplate,
--                fillToInterior) : le premier TOPLEFT sur le TOPRIGHT
--                (0, -60), chacun sous le précédent (0, -2) ; infobulle
--                tooltipText ; SelectPage : la page montrée, son onglet
--                coché ; les pages au niveau 100
--   bouton rouge ThreeSliceButtonTemplate : Left et Right à leur taille
--                d'atlas mise à l'échelle de la hauteur du bouton, Center
--                tendu entre eux, rognés s'ils ne tiennent pas dans la
--                largeur (UpdateScale) ; états -Pressed et -Disabled ;
--                lueur <atlas>-Highlight en ADD ; texte enfoncé de (-2, -1)
--   micro-bouton LegacyMicroButton : LoadMicroButtonTextures "Legacy",
--                après les talents ; grisé tant que le système est
--                verrouillé, enfoncé tant que la fenêtre est ouverte
--
-- CE QUI DIFFÈRE, ET POURQUOI.
--   * Les pages sont celles que déclarent les modules, par P.Ajouter. Chaque
--     page déclarée demande le micro-bouton : le premier module le crée, le
--     second le trouve déjà là ; sans module, il n'existe pas (demande du
--     2026-09-29). Camelot, lui, le grise.
--   * Un disque noir sous le portrait, dans le cercle (demande du
--     2026-09-29 : « l'icône dans le cercle du portrait de la fenêtre doit
--     avoir un fond noir ») : celui du portrait rond de PortraitFrameTemplate
--     (62 x 62 à (-5, 7), rogné par son CircleMask de (2, 0) à (-2, 4) : 58 x
--     58 à (-3, 7)), TempPortraitAlphaMask noirci, sous l'anneau de métal.
--   * La fenêtre a la taille de celle des métiers de ForeverUI (673 x 594) :
--     la page d'Item Upgrade reprend sa page de fabrication, à ses nombres.
--     La largeur du panneau garde la marge de camelot (1005 pour 920 : 85,
--     onglets compris).
--   * Un titre, « Progression » : le nom retenu par l'utilisateur. Il vient
--     des textes du module qui le donne (nomFenetre), lus à l'affichage : les
--     textes d'un module arrivent après son code.
--   * 3.3.5 n'a pas de masque : le portrait est une image où l'ellipse du
--     CircleMask est cuite. Chaque module installe la sienne (son
--     installeur l'écrit dans l'archive du jeu) et la donne à P.Ajouter ; la
--     fenêtre prend celle du module qui la crée.
--   * 3.3.5 n'a ni atlas ni découpe en neuf : les éléments se posent par
--     leurs coordonnées dans leur feuille (tables ci-dessous), les découpes
--     en morceaux posés à la main.
--   * Le panneau se déclare par ses attributs UIPanelLayout-*, sans toucher
--     à la table UIPanelWindows du client.
--   * UNE PAGE PEUT DEMANDER SA TAILLE (demande du 2026-10-17 : l'onglet de
--     Stellar Tarot « doit redimensionner la page pour que toute l'interface
--     rentre correctement. Si la page venait à sortir de l'écran, il faut la
--     repositionner correctement ») : la fenêtre prend la taille de la page
--     choisie, celle de 673 x 594 sinon ; trop grande pour l'écran, elle se
--     réduit (son échelle) ; sortie de l'écran, elle y revient.
--
-- CE QUE LES MODULES APPELLENT (ils testent Progression.Ajouter et
-- Progression.Kit) :
--   P.Ajouter{ cle, ordre, titre, icone, construire, nomFenetre, portrait, taille }
--     -- déclare une page et rend son cadre (toute la fenêtre ;
--     construire(page) le remplit, une fois, à sa première ouverture). titre :
--     un texte, ou une fonction qui le rend. ordre : la place de l'onglet (le
--     plus petit en haut). nomFenetre : le nom de la fenêtre et du
--     micro-bouton (texte ou fonction) ; portrait : le fichier du portrait ;
--     ceux de la page qui crée la fenêtre. taille : { largeur, hauteur } de
--     la fenêtre quand cette page est choisie (sinon 673 x 594). Redéclarer
--     une clé (un « .reload ale ») remplace sa page par un cadre neuf.
--   P.Ouvrir(cle), P.Basculer(cle), P.Fermer(), P.Montree(cle).
--   P.Kit : la trousse de dessin écrite ici (voir plus bas) ; une page y
--     ajoute les coordonnées de ses propres éléments par K.AjouterArt.
if not (Progression and Progression.Ajouter) and ForeverUI and ForeverUI.AddMicroButton then
    Progression = {}
    local P = Progression
    local SEP = string.char(92)
    local ART = "Interface" .. SEP .. "ForeverUI" .. SEP
    local BOUTON = "ProgressionMicroButton"

    local N = {
        fenetre = { 673, 594 },
        -- l'image du portrait : la région utile de sa toile (198 x 273 sur
        -- 256 x 512), posée en 45 x 62
        portrait = { 45, 62, x = 2, y = 10, coords = { 0, 0.773438, 0, 0.533203 } },
        disque = { 58, x = -3, y = 7, fichier = ART .. "characterframe" .. SEP .. "tempportraitalphamask" },
        roche = { fichier = "interface" .. SEP .. "ForeverUI" .. SEP .. "framegeneral" .. SEP .. "ui-background-rock", 2, -21, -2, 2 },
        stries = { 43, x = 6, y = -21, x2 = -2 },
        metal = {
            { nom = "ui-frame-portraitmetal-cornertopleft", point = "TOPLEFT", x = -13, y = 16 },
            { nom = "ui-frame-metal-cornertopright", point = "TOPRIGHT", x = 2, y = 16 },
            { nom = "ui-frame-metal-cornerbottomleft", point = "BOTTOMLEFT", x = -13, y = -8 },
            { nom = "ui-frame-metal-cornerbottomright", point = "BOTTOMRIGHT", x = 2, y = -8 },
        },
        titre = { x1 = 58, x2 = -24, y = -1, h = 20, texteY = -5 },
        -- les onglets latéraux (ceux du livre des métiers de ForeverUI)
        onglet = { cote = 55, y = -60, ecart = -2, icone = 50, iconeX = -3, rognage = 0.03125 },
        niveaux = { page = 1, onglets = 1, portrait = 19, metal = 20, titre = 21, croix = 22 },
    }

    -- RegisterUIPanel de camelot, plus whileDead (3.3.5 ne l'ouvre pas sans)
    local PANNEAU = { area = "left", xoffset = 35, pushable = 1, whileDead = 1, width = N.fenetre[1] + 85 }

    P.pages = {}
    P.ordre = {}

    -- ------------------------------------------------------------ la trousse

    -- LES ÉLÉMENTS, par leurs coordonnées dans les feuilles que ForeverUI
    -- installe (les éléments de camelot, aux tailles qu'il leur donne).
    -- art : { fichier, u1, u2, v1, v2, largeur, hauteur } ; decoupes : les
    -- éléments qui se découpent en morceaux (bouton rouge, croix, cadre
    -- intérieur), { fichier, u1, u2, v1, v2, largeur, hauteur, mosaïque
    -- horizontale, mosaïque verticale, découpe { gauche, haut, droite, bas } }.
    local K = { art = {}, decoupes = {} }
    P.Kit = K

    function K.AjouterArt(art, decoupes)
        for nom, e in pairs(art or {}) do K.art[nom] = e end
        for nom, e in pairs(decoupes or {}) do K.decoupes[nom] = e end
    end

    K.AjouterArt({
        ["!ui-frame-metal-edgeleft"] = { "interface\\ForeverUI\\framegeneral\\uiframemetalvertical2xc60", 0.001953, 0.373047, 0, 1, 95, 128 },
        ["!ui-frame-metal-edgeright"] = { "interface\\ForeverUI\\framegeneral\\uiframemetalvertical2xc60", 0.376953, 0.748047, 0, 1, 95, 128 },
        ["_ui-frame-metal-edgebottom"] = { "interface\\ForeverUI\\framegeneral\\uiframemetalhorizontal2xc60", 0, 1, 0.001953, 0.392578, 128, 100 },
        ["_ui-frame-metal-edgetop"] = { "interface\\ForeverUI\\framegeneral\\uiframemetalhorizontal2xc60", 0, 1, 0.396484, 0.767578, 128, 95 },
        ["_ui-frame-toptilestreaks"] = { "interface\\ForeverUI\\framegeneral\\uiframehorizontal", 0, 1, 0.007812, 0.34375, 256, 43 },
        ["common-sidetab"] = { "interface\\ForeverUI\\common\\commonsidetabc60", 0.007812, 0.4375, 0.007812, 0.476562, 55, 60 },
        ["common-sidetab-hover"] = { "interface\\ForeverUI\\common\\commonsidetabc60", 0.007812, 0.4375, 0.492188, 0.960938, 55, 60 },
        ["common-sidetab-selected"] = { "interface\\ForeverUI\\common\\commonsidetabc60", 0.453125, 0.882812, 0.007812, 0.476562, 55, 60 },
        ["common-stat-bar-bg"] = { "interface\\ForeverUI\\common\\commonstatbarc60", 0.003906, 0.265625, 0.539062, 0.765625, 67, 29 },
        ["ui-frame-metal-cornerbottomleft"] = { "interface\\ForeverUI\\framegeneral\\uiframemetal2xc60", 0.000977, 0.186523, 0.001953, 0.392578, 95, 100 },
        ["ui-frame-metal-cornerbottomright"] = { "interface\\ForeverUI\\framegeneral\\uiframemetal2xc60", 0.000977, 0.186523, 0.396484, 0.787109, 95, 100 },
        ["ui-frame-metal-cornertopright"] = { "interface\\ForeverUI\\framegeneral\\uiframemetal2xc60", 0.188477, 0.374023, 0.376953, 0.748047, 95, 95 },
        ["ui-frame-portraitmetal-cornertopleft"] = { "interface\\ForeverUI\\framegeneral\\uiframemetal2xc60", 0.375977, 0.561523, 0.376953, 0.748047, 95, 95 },
    }, {
        ["redbutton-exit"] = { "interface\\ForeverUI\\buttons\\redbuttonsc60", 0.136719, 0.261719, 0.007812, 0.257812, 32, 32, nil, nil },
        ["redbutton-exit-disabled"] = { "interface\\ForeverUI\\buttons\\redbuttonsc60", 0.136719, 0.261719, 0.273438, 0.523438, 32, 32, nil, nil },
        ["redbutton-exit-pressed"] = { "interface\\ForeverUI\\buttons\\redbuttonsc60", 0.136719, 0.261719, 0.539062, 0.789062, 32, 32, nil, nil },
        ["redbutton-highlight"] = { "interface\\ForeverUI\\buttons\\redbuttonsc60", 0.402344, 0.527344, 0.007812, 0.257812, 32, 32, nil, nil },
    })

    -- la jauge des barres, celle de l'onglet Compétences : common-stat-bar-bg
    -- découpée à 10, 29 de haut, remplissage bleu de 15
    K.Jauge = { fond = "common-stat-bar-bg", coin = 10, hauteur = 29, remplissage = 15,
        fichier = ART .. "Bars" .. SEP .. "statbarfillblue" }

    function K.AtlasEntry(nom)
        return K.art[nom]
    end

    -- l'élément sur la texture ; garderTaille : sans lui, la texture prend
    -- sa taille. Rend vrai s'il est connu.
    function K.SetAtlas(t, nom, garderTaille)
        local e = K.art[nom]
        if not e then return false end
        t:SetTexture(e[1])
        t:SetTexCoord(e[2], e[3], e[4], e[5])
        if not garderTaille then
            t:SetWidth(e[6])
            t:SetHeight(e[7])
        end
        return true
    end

    function K.Montrer(r, oui)
        if oui then r:Show() else r:Hide() end
    end

    -- 3.3.5 rend 1 / nil, parfois 0 / 1 : zéro est vrai en Lua
    local function vrai(v)
        return v and v ~= 0 and true or false
    end

    -- EN NEUF : les coins gardent leur taille (coin), les bords ne s'étirent
    -- que dans un sens, le centre dans les deux ; marges { gauche, haut,
    -- droite, bas } : de combien l'image déborde du cadre. Rend les neuf
    -- morceaux, en régions du cadre, sur le calque donné.
    function K.NeufTranches(cadre, nom, coin, marges, calque)
        local e = K.art[nom]
        if not e then return nil end
        local du = (e[3] - e[2]) * coin / e[6]
        local dv = (e[5] - e[4]) * coin / e[7]
        local us = { e[2], e[2] + du, e[3] - du, e[3] }
        local vs = { e[4], e[4] + dv, e[5] - dv, e[5] }
        local morceaux = {}
        local function morceau(colonne, ligne)
            local t = cadre:CreateTexture(nil, calque or "BACKGROUND")
            t:SetTexture(e[1])
            t:SetTexCoord(us[colonne], us[colonne + 1], vs[ligne], vs[ligne + 1])
            morceaux[#morceaux + 1] = t
            return t
        end
        local hg, hd, bg, bd = morceau(1, 1), morceau(3, 1), morceau(1, 3), morceau(3, 3)
        local haut, bas = morceau(2, 1), morceau(2, 3)
        local gauche, droite = morceau(1, 2), morceau(3, 2)
        local centre = morceau(2, 2)
        for _, t in ipairs({ hg, hd, bg, bd }) do
            t:SetWidth(coin)
            t:SetHeight(coin)
        end
        haut:SetHeight(coin)
        bas:SetHeight(coin)
        gauche:SetWidth(coin)
        droite:SetWidth(coin)
        local G, H, D, B = marges[1], marges[2], marges[3], marges[4]
        hg:SetPoint("TOPLEFT", cadre, "TOPLEFT", -G, H)
        hd:SetPoint("TOPRIGHT", cadre, "TOPRIGHT", D, H)
        bg:SetPoint("BOTTOMLEFT", cadre, "BOTTOMLEFT", -G, -B)
        bd:SetPoint("BOTTOMRIGHT", cadre, "BOTTOMRIGHT", D, -B)
        haut:SetPoint("TOPLEFT", hg, "TOPRIGHT")
        haut:SetPoint("TOPRIGHT", hd, "TOPLEFT")
        bas:SetPoint("BOTTOMLEFT", bg, "BOTTOMRIGHT")
        bas:SetPoint("BOTTOMRIGHT", bd, "BOTTOMLEFT")
        gauche:SetPoint("TOPLEFT", hg, "BOTTOMLEFT")
        gauche:SetPoint("BOTTOMRIGHT", bg, "TOPRIGHT")
        droite:SetPoint("TOPLEFT", hd, "BOTTOMLEFT")
        droite:SetPoint("BOTTOMRIGHT", bd, "TOPRIGHT")
        centre:SetPoint("TOPLEFT", hg, "BOTTOMRIGHT")
        centre:SetPoint("BOTTOMRIGHT", bd, "TOPLEFT")
        return morceaux
    end

    -- UN SÉPARATEUR VERTICAL EN TROIS : un embout en haut et en bas (embout
    -- pixels de l'image), le milieu tiré entre eux ; étirer l'élément entier
    -- étalerait ses embouts.
    function K.SeparateurVertical(parent, nom, embout, niveau)
        local e = K.art[nom]
        local cadre = CreateFrame("Frame", nil, parent)
        if not e then
            cadre:Hide()
            return cadre
        end
        embout = embout or 4
        cadre:SetWidth(e[6])
        cadre:SetFrameLevel(niveau or parent:GetFrameLevel())
        local dv = (e[5] - e[4]) * embout / e[7]
        local function tranche(v1, v2)
            local t = cadre:CreateTexture(nil, "OVERLAY")
            t:SetTexture(e[1])
            t:SetTexCoord(e[2], e[3], v1, v2)
            return t
        end
        local haut = tranche(e[4], e[4] + dv)
        haut:SetHeight(embout)
        haut:SetPoint("TOPLEFT", cadre, "TOPLEFT")
        haut:SetPoint("TOPRIGHT", cadre, "TOPRIGHT")
        local bas = tranche(e[5] - dv, e[5])
        bas:SetHeight(embout)
        bas:SetPoint("BOTTOMLEFT", cadre, "BOTTOMLEFT")
        bas:SetPoint("BOTTOMRIGHT", cadre, "BOTTOMRIGHT")
        local milieu = tranche(e[4] + dv, e[5] - dv)
        milieu:SetPoint("TOPLEFT", haut, "BOTTOMLEFT")
        milieu:SetPoint("BOTTOMRIGHT", bas, "TOPRIGHT")
        cadre.haut, cadre.milieu, cadre.bas = haut, milieu, bas
        return cadre
    end

    -- un élément à découper, posé sur une texture (sans changer sa taille) ;
    -- rend l'élément
    local function poserDecoupe(t, nom)
        local e = K.decoupes[nom]
        if not e then return nil end
        t:SetTexture(e[1])
        t:SetTexCoord(e[2], e[3], e[4], e[5])
        return e
    end

    -- L'ÉLÉMENT ÉTIRÉ. Un élément à découpe se pose en morceaux autour d'un
    -- rectangle invisible (rect) que la page ancre comme elle ancrerait
    -- l'élément : les marges gardent leur taille, le reste s'étire. Rend
    -- { rect, Poser(nom), Montrer(oui), Alpha(a) }.
    local function decouperEtire(obj)
        local e = obj.e
        local d = e[10]
        for _, t in ipairs(obj.morceaux) do t:Hide() end
        if not d then
            obj.rect:SetTexture(e[1])
            obj.rect:SetTexCoord(e[2], e[3], e[4], e[5])
            return
        end
        obj.rect:SetTexture(nil)
        local W, Ht = e[6], e[7]
        local g, h, dr, b = d[1], d[2], d[3], d[4]
        local us = { e[2], e[2] + (e[3] - e[2]) * g / W, e[3] - (e[3] - e[2]) * dr / W, e[3] }
        local vs = { e[4], e[4] + (e[5] - e[4]) * h / Ht, e[5] - (e[5] - e[4]) * b / Ht, e[5] }
        local largeurs, hauteurs = { g, nil, dr }, { h, nil, b }
        local r, n = obj.rect, 0
        for ligne = 1, 3 do
            for col = 1, 3 do
                local lw, lh = largeurs[col], hauteurs[ligne]
                if (lw == nil or lw > 0) and (lh == nil or lh > 0) then
                    n = n + 1
                    local t = obj.morceaux[n]
                    if not t then
                        t = obj.hote:CreateTexture(nil, obj.calque)
                        obj.morceaux[n] = t
                    end
                    t:SetTexture(e[1])
                    t:SetTexCoord(us[col], us[col + 1], vs[ligne], vs[ligne + 1])
                    t:ClearAllPoints()
                    if col == 1 then
                        t:SetPoint("LEFT", r, "LEFT")
                        t:SetWidth(lw)
                    elseif col == 3 then
                        t:SetPoint("RIGHT", r, "RIGHT")
                        t:SetWidth(lw)
                    else
                        t:SetPoint("LEFT", r, "LEFT", g, 0)
                        t:SetPoint("RIGHT", r, "RIGHT", -dr, 0)
                    end
                    if ligne == 1 then
                        t:SetPoint("TOP", r, "TOP")
                        t:SetHeight(lh)
                    elseif ligne == 3 then
                        t:SetPoint("BOTTOM", r, "BOTTOM")
                        t:SetHeight(lh)
                    else
                        t:SetPoint("TOP", r, "TOP", 0, -h)
                        t:SetPoint("BOTTOM", r, "BOTTOM", 0, b)
                    end
                    if obj.visible ~= false then t:Show() end
                end
            end
        end
        obj.nombre = n
    end

    function K.AtlasEtire(hote, nom, calque)
        local obj = { hote = hote, calque = calque or "ARTWORK", morceaux = {} }
        obj.rect = hote:CreateTexture(nil, obj.calque)
        function obj:Poser(n)
            self.e = K.decoupes[n]
            decouperEtire(self)
        end
        function obj:Montrer(oui)
            self.visible = oui and true or false
            if self.e[10] then
                for i = 1, self.nombre or 0 do K.Montrer(self.morceaux[i], oui) end
            else
                K.Montrer(self.rect, oui)
            end
        end
        function obj:Alpha(a)
            self.rect:SetAlpha(a)
            for _, t in ipairs(self.morceaux) do t:SetAlpha(a) end
        end
        obj:Poser(nom)
        return obj
    end

    -- efface l'art que le client 3.3.5 pose sur ses propres boutons
    local function effacerArt(b)
        for _, lire in ipairs({ "GetNormalTexture", "GetPushedTexture", "GetDisabledTexture", "GetHighlightTexture" }) do
            local t = b[lire] and b[lire](b)
            if t then t:SetTexture(nil) end
        end
    end

    -- LE BOUTON ROUGE (ThreeSliceButtonTemplate) : voir le relevé plus haut.
    local function rogner(t, e, gaucheVersDroite, part)
        local u1, u2 = e[2], e[3]
        if gaucheVersDroite then
            t:SetTexCoord(u1, u1 + (u2 - u1) * part, e[4], e[5])
        else
            t:SetTexCoord(u2 - (u2 - u1) * part, u2, e[4], e[5])
        end
    end

    local function peindreTrois(b, etat)
        local r = b.trois
        if not vrai(b:IsEnabled()) then etat = "DISABLED" end
        local suffixe = (etat == "DISABLED" and "-disabled") or (etat == "PUSHED" and "-pressed") or ""
        local eg = poserDecoupe(r.gauche, r.atlas .. "-left" .. suffixe)
        poserDecoupe(r.centre, "_" .. r.atlas .. "-center" .. suffixe)
        local ed = poserDecoupe(r.droite, r.atlas .. "-right" .. suffixe)
        -- UpdateScale
        local hauteur, largeur = b:GetHeight(), b:GetWidth()
        local echelle = hauteur / eg[7]
        local lg, ld = eg[6] * echelle, ed[6] * echelle
        if lg + ld > largeur then
            local surplus = lg + ld - largeur
            local ng, nd = lg, ld
            if (lg - surplus) > ld then
                ng = lg - surplus
            elseif (ld - surplus) > lg then
                nd = ld - surplus
            else
                if lg ~= ld then
                    surplus = surplus - math.abs(lg - ld)
                    ng = math.min(lg, ld)
                    nd = ng
                end
                ng = ng - surplus / 2
                nd = nd - surplus / 2
            end
            rogner(r.gauche, eg, true, ng / lg)
            rogner(r.droite, ed, false, nd / ld)
            lg, ld = ng, nd
        end
        r.gauche:SetWidth(lg)
        r.gauche:SetHeight(hauteur)
        r.droite:SetWidth(ld)
        r.droite:SetHeight(hauteur)
        r.actif = vrai(b:IsEnabled())
    end

    -- atlas : le nom de l'élément, sans son suffixe (« 128-redbutton ») ;
    -- polices : { normale, survol, grisée }, des objets police
    function K.BoutonTroisTranches(b, atlas, polices)
        effacerArt(b)
        local r = { atlas = atlas }
        r.gauche = b:CreateTexture(nil, "BACKGROUND")
        r.gauche:SetPoint("TOPLEFT", b, "TOPLEFT")
        r.droite = b:CreateTexture(nil, "BACKGROUND")
        r.droite:SetPoint("TOPRIGHT", b, "TOPRIGHT")
        r.centre = b:CreateTexture(nil, "BACKGROUND")
        r.centre:SetPoint("TOPLEFT", r.gauche, "TOPRIGHT")
        r.centre:SetPoint("BOTTOMRIGHT", r.droite, "BOTTOMLEFT")
        b.trois = r
        -- la lueur, sur tout le bouton, en ADD
        b:SetHighlightTexture(K.decoupes[atlas .. "-highlight"][1])
        local lueur = b:GetHighlightTexture()
        poserDecoupe(lueur, atlas .. "-highlight")
        lueur:ClearAllPoints()
        lueur:SetAllPoints(b)
        lueur:SetBlendMode("ADD")
        if polices then
            b:SetNormalFontObject(polices[1])
            b:SetHighlightFontObject(polices[2] or polices[1])
            b:SetDisabledFontObject(polices[3] or polices[1])
        end
        local texte = b:GetFontString()
        if texte then
            texte:ClearAllPoints()
            texte:SetPoint("CENTER", b, "CENTER", 0, 0)
        end
        b:SetPushedTextOffset(-2, -1)
        b:HookScript("OnMouseDown", function(self)
            if vrai(self:IsEnabled()) then peindreTrois(self, "PUSHED") end
        end)
        b:HookScript("OnMouseUp", function(self) peindreTrois(self, "NORMAL") end)
        b:HookScript("OnShow", function(self) peindreTrois(self, "NORMAL") end)
        b:HookScript("OnSizeChanged", function(self) peindreTrois(self, "NORMAL") end)
        b:HookScript("OnEnable", function(self) peindreTrois(self, "NORMAL") end)
        b:HookScript("OnDisable", function(self) peindreTrois(self, "NORMAL") end)
        peindreTrois(b, "NORMAL")
        return b
    end

    -- la croix (UIPanelCloseButton) : voir le relevé plus haut
    local function croix(b, fenetre)
        b:SetWidth(24)
        b:SetHeight(24)
        b:ClearAllPoints()
        b:SetPoint("TOPRIGHT", fenetre, "TOPRIGHT", -2, 1)
        for _, v in ipairs({
            { "SetNormalTexture", "GetNormalTexture", "redbutton-exit" },
            { "SetPushedTexture", "GetPushedTexture", "redbutton-exit-pressed" },
            { "SetDisabledTexture", "GetDisabledTexture", "redbutton-exit-disabled" },
            { "SetHighlightTexture", "GetHighlightTexture", "redbutton-highlight" },
        }) do
            b[v[1]](b, K.decoupes[v[3]][1])
            local t = b[v[2]](b)
            poserDecoupe(t, v[3])
            t:ClearAllPoints()
            t:SetAllPoints(b)
            if v[1] == "SetHighlightTexture" then t:SetBlendMode("ADD") end
        end
        return b
    end

    -- le cadre (PortraitFrameTemplate) : voir le relevé plus haut
    local function habiller(f, portrait)
        local R = N.roche
        local roche = f:CreateTexture(nil, "BACKGROUND")
        roche:SetTexture(R.fichier, true)
        if roche.SetHorizTile then
            roche:SetHorizTile(true)
            roche:SetVertTile(true)
        end
        roche:SetPoint("TOPLEFT", f, "TOPLEFT", R[1], R[2])
        roche:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", R[3], R[4])
        local stries = f:CreateTexture(nil, "BACKGROUND")
        K.SetAtlas(stries, "_ui-frame-toptilestreaks", true)
        stries:SetHeight(N.stries[1])
        stries:SetPoint("TOPLEFT", f, "TOPLEFT", N.stries.x, N.stries.y)
        stries:SetPoint("TOPRIGHT", f, "TOPRIGHT", N.stries.x2, N.stries.y)
        local metal = CreateFrame("Frame", nil, f)
        metal:SetAllPoints(f)
        metal:SetFrameLevel(f:GetFrameLevel() + N.niveaux.metal)
        local coins = {}
        for i, coin in ipairs(N.metal) do
            local t = metal:CreateTexture(nil, "OVERLAY")
            K.SetAtlas(t, coin.nom)
            t:SetPoint(coin.point, metal, coin.point, coin.x, coin.y)
            coins[i] = t
        end
        local function bord(nom, a1, c1, r1, a2, c2, r2)
            local t = metal:CreateTexture(nil, "OVERLAY")
            K.SetAtlas(t, nom)
            t:SetPoint(a1, c1, r1)
            t:SetPoint(a2, c2, r2)
        end
        bord("_ui-frame-metal-edgetop", "TOPLEFT", coins[1], "TOPRIGHT", "TOPRIGHT", coins[2], "TOPLEFT")
        bord("_ui-frame-metal-edgebottom", "BOTTOMLEFT", coins[3], "BOTTOMRIGHT", "BOTTOMRIGHT", coins[4], "BOTTOMLEFT")
        bord("!ui-frame-metal-edgeleft", "TOPLEFT", coins[1], "BOTTOMLEFT", "BOTTOMLEFT", coins[3], "TOPLEFT")
        bord("!ui-frame-metal-edgeright", "TOPRIGHT", coins[2], "BOTTOMRIGHT", "BOTTOMRIGHT", coins[4], "TOPRIGHT")
        local cadrePortrait = CreateFrame("Frame", nil, f)
        cadrePortrait:SetAllPoints(f)
        cadrePortrait:SetFrameLevel(f:GetFrameLevel() + N.niveaux.portrait)
        local Pt = N.portrait
        local image = cadrePortrait:CreateTexture(nil, "OVERLAY")
        image:SetWidth(Pt[1])
        image:SetHeight(Pt[1])
        image:SetPoint("TOPLEFT", f, "TOPLEFT", Pt.x, Pt.y)
        image:SetTexture(portrait)
        local T = N.titre
        local bandeau = CreateFrame("Frame", nil, f)
        bandeau:SetFrameLevel(f:GetFrameLevel() + N.niveaux.titre)
        bandeau:SetHeight(T.h)
        bandeau:SetPoint("TOPLEFT", f, "TOPLEFT", T.x1, T.y)
        bandeau:SetPoint("TOPRIGHT", f, "TOPRIGHT", T.x2, T.y)
        local titre = bandeau:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        titre:SetPoint("TOP", bandeau, "TOP", 0, T.texteY)
        titre:SetText("")
        -- 45 x 62, la région utile de l'image
        image:SetHeight(Pt[2])
        image:SetTexCoord(Pt.coords[1], Pt.coords[2], Pt.coords[3], Pt.coords[4])
        -- le fond noir du cercle, sous le portrait (même cadre, calque inférieur)
        local D = N.disque
        local disque = cadrePortrait:CreateTexture(nil, "ARTWORK")
        disque:SetTexture(D.fichier)
        disque:SetVertexColor(0, 0, 0, 1)
        disque:SetWidth(D[1])
        disque:SetHeight(D[1])
        disque:SetPoint("TOPLEFT", f, "TOPLEFT", D.x, D.y)
        return { roche = roche, stries = stries, metal = metal, portrait = image, titre = titre,
            bandeau = bandeau, cadrePortrait = cadrePortrait, disque = disque }
    end

    local function poser(r, ...)
        r:ClearAllPoints()
        r:SetPoint(...)
    end

    local function texte(v)
        if type(v) == "function" then return v() end
        return v
    end

    -- LE MICRO-BOUTON, dans la micro-barre de ForeverUI : demandé dès qu'une
    -- page existe (ForeverUI.AddMicroButton le crée une fois, après les
    -- talents, avec son jeu d'icônes Legacy ; en combat, à la sortie du
    -- combat), enfoncé tant que la fenêtre est ouverte.
    local majMicro
    local MICRO = {
        name = BOUTON, atlasSet = "legacy", after = "TalentMicroButton",
        tooltip = function() return texte(P.nom) or "" end,
        onClick = function() P.Basculer() end,
        ready = function() majMicro() end,
    }
    majMicro = function()
        if #P.ordre > 0 then
            ForeverUI.AddMicroButton(MICRO)
        end
        if ForeverUI.UpdateMicro then
            ForeverUI.UpdateMicro(BOUTON, (P.fenetre and P.fenetre:IsShown()) and true or false)
        end
    end

    -- ------------------------------------------------------------ les onglets

    -- SUR UNE BARRE D'ACTION (demande du 2026-10-19 : « le joueur doit pouvoir
    -- drag & drop l'icone d'un onglet dans sa barre d'action. si le joueur
    -- clique sur ces icones, il faut ouvrir l'interface correspondante ») :
    -- avec ForeverUI.TabMacros (sa barre d'action), l'onglet glissé devient une
    -- macro qui bascule sa page (P.Basculer) ; sur la barre, elle porte
    -- l'icône de l'onglet. Le corps se lit au clic : la fenêtre peut ne pas
    -- encore exister.
    local function corpsMacro(cle)
        return '/run if Progression then Progression.Basculer("' .. cle .. '") end'
    end
    local function infoMacro(cle)
        return {
            name = function() local d = P.pages[cle] return d and texte(d.titre) end,
            icon = function() local d = P.pages[cle] return d and d.icone end,
        }
    end

    local function creerOnglet(f, k)
        local O = N.onglet
        local b = CreateFrame("Button", "ProgressionTab" .. k, f)
        b:SetWidth(O.cote)
        b:SetHeight(O.cote)
        b:SetFrameLevel(f:GetFrameLevel() + N.niveaux.onglets)
        b:RegisterForClicks("LeftButtonUp")
        local fond = b:CreateTexture(nil, "BACKGROUND")
        K.SetAtlas(fond, "common-sidetab", true)
        fond:SetAllPoints(b)
        local icone = b:CreateTexture(nil, "ARTWORK")
        icone:SetWidth(O.icone)
        icone:SetHeight(O.icone)
        icone:SetPoint("CENTER", b, "CENTER", O.iconeX, 0)
        icone:SetTexCoord(O.rognage, 1 - O.rognage, O.rognage, 1 - O.rognage)
        local choisi = b:CreateTexture(nil, "OVERLAY")
        K.SetAtlas(choisi, "common-sidetab-selected", true)
        choisi:SetAllPoints(b)
        choisi:Hide()
        local survol = b:CreateTexture(nil, "HIGHLIGHT")
        K.SetAtlas(survol, "common-sidetab-hover", true)
        survol:SetAllPoints(b)
        b.icone, b.choisi = icone, choisi
        b:SetScript("OnEnter", function(self)
            local d = P.pages[self.cle or ""]
            if not d then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -4, -4)
            GameTooltip:SetText(texte(d.titre) or "")
            GameTooltip:Show()
        end)
        b:SetScript("OnLeave", function() GameTooltip:Hide() end)
        b:SetScript("OnMouseDown", function(self, bouton)
            if bouton == "LeftButton" then poser(self.icone, "CENTER", self, "CENTER", O.iconeX + 1, -1) end
        end)
        b:SetScript("OnMouseUp", function(self, bouton)
            if bouton == "LeftButton" then
                poser(self.icone, "CENTER", self, "CENTER", O.iconeX, 0)
                PlaySound("igCharacterInfoTab")
            end
        end)
        b:SetScript("OnClick", function(self)
            if self.cle then P.Choisir(self.cle) end
        end)
        if ForeverUI and ForeverUI.TabMacros then
            ForeverUI.TabMacros.EnableDrag(b, function(self)
                if self.cle and P.pages[self.cle] then
                    return corpsMacro(self.cle), infoMacro(self.cle)
                end
            end)
        end
        if k == 1 then
            b:SetPoint("TOPLEFT", f, "TOPRIGHT", 0, O.y)
        else
            b:SetPoint("TOPLEFT", f.onglets[k - 1], "BOTTOMLEFT", 0, O.ecart)
        end
        return b
    end

    local function majOnglets()
        local f = P.fenetre
        if not f then return end
        for k, cle in ipairs(P.ordre) do
            local d = P.pages[cle]
            local b = f.onglets[k] or creerOnglet(f, k)
            f.onglets[k] = b
            b.cle = cle
            b.icone:SetTexture(d.icone)
            K.Montrer(b.choisi, cle == P.courante)
            b:Show()
        end
        for k = #P.ordre + 1, #f.onglets do f.onglets[k]:Hide() end
    end

    -- ------------------------------------------------------------ la fenêtre

    function P.Construire(portrait)
        if P.fenetre then return P.fenetre end
        local f = CreateFrame("Frame", "ProgressionFrame", UIParent)
        f:SetWidth(N.fenetre[1])
        f:SetHeight(N.fenetre[2])
        f:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, -104)
        f:SetToplevel(true)
        f:EnableMouse(true)
        f:Hide()
        -- le panneau, déclaré par ses attributs (GetUIPanelWindowInfo les lit
        -- avant la table UIPanelWindows)
        for k, v in pairs(PANNEAU) do
            f:SetAttribute("UIPanelLayout-" .. k, v)
        end
        f:SetAttribute("UIPanelLayout-defined", true)
        f:SetAttribute("UIPanelLayout-enabled", true)
        local habit = habiller(f, portrait)
        f.habit = habit
        local b = CreateFrame("Button", "ProgressionFrameCloseButton", f, "UIPanelCloseButton")
        croix(b, f)
        b:SetFrameLevel(f:GetFrameLevel() + N.niveaux.croix)
        f.croix = b
        f.onglets = {}
        -- DÉPLAÇABLE (demande du 2026-10-17 : « la fenêtre doit pouvoir être
        -- déplacée ») par sa barre de titre, croix exceptée. La place choisie
        -- (P.place, en unités de l'écran) l'emporte ensuite sur celle que
        -- donne le client, le temps de la session.
        f:SetMovable(true)
        local poignee = CreateFrame("Frame", nil, f)
        poignee:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
        poignee:SetPoint("TOPRIGHT", f, "TOPRIGHT", N.titre.x2, 0)
        poignee:SetHeight(-N.roche[2])
        poignee:SetFrameLevel(f:GetFrameLevel() + N.niveaux.titre)
        poignee:EnableMouse(true)
        poignee:RegisterForDrag("LeftButton")
        poignee:SetScript("OnDragStart", function() f:StartMoving() end)
        poignee:SetScript("OnDragStop", function()
            f:StopMovingOrSizing()
            f:SetUserPlaced(false)
            local s = f:GetScale()
            P.place = { f:GetLeft() * s, f:GetTop() * s }
            P.Recadrer()
        end)
        f.poignee = poignee
        f:SetScript("OnShow", function()
            habit.titre:SetText(texte(P.nom) or "")
            PlaySound("igCharacterInfoOpen")
            majMicro()
        end)
        f:SetScript("OnHide", function()
            PlaySound("igCharacterInfoClose")
            majMicro()
        end)
        P.fenetre = f
        -- le client la place (ShowUIPanel, UpdateUIPanelPositions) : puis elle
        -- se garde dans l'écran, et encore quand l'écran ou l'échelle change
        hooksecurefunc("UpdateUIPanelPositions", function() P.Recadrer() end)
        if FramePositionDelegate and FramePositionDelegate.UpdateUIPanelPositions then
            hooksecurefunc(FramePositionDelegate, "UpdateUIPanelPositions", function() P.Recadrer() end)
        end
        f:RegisterEvent("DISPLAY_SIZE_CHANGED")
        f:RegisterEvent("UI_SCALE_CHANGED")
        f:SetScript("OnEvent", function() P.Recadrer() end)
        return f
    end

    -- LA TAILLE DE LA PAGE CHOISIE : la sienne, sinon celle de la fenêtre. Le
    -- panneau déclare sa nouvelle largeur (onglets compris, comme plus haut).
    local function dimensionner(d)
        local f = P.fenetre
        local t = (d and d.taille) or N.fenetre
        local w, h = t[1] or N.fenetre[1], t[2] or N.fenetre[2]
        if math.abs(f:GetWidth() - w) < 0.5 and math.abs(f:GetHeight() - h) < 0.5 then return false end
        f:SetWidth(w)
        f:SetHeight(h)
        f:SetAttribute("UIPanelLayout-width", w + 85)
        return true
    end

    -- DANS L'ÉCRAN : plus grande que lui, la fenêtre se réduit -- les onglets
    -- à sa droite et le métal qui la déborde compris ; sortie de l'écran, elle
    -- y revient.
    local DEBORDS = { gauche = 13, droite = N.onglet.cote + 2, haut = 16, bas = 8 }
    function P.Recadrer()
        local f = P.fenetre
        if not (f and f:IsShown()) then return end
        local D = DEBORDS
        local W, H = UIParent:GetWidth(), UIParent:GetHeight()
        local w = f:GetWidth() + D.gauche + D.droite
        local h = f:GetHeight() + D.haut + D.bas
        local s = math.min(1, W / w, H / h)
        if math.abs(f:GetScale() - s) > 0.001 then f:SetScale(s) end
        -- la place : celle où le joueur l'a posée, sinon celle du client
        local l, t
        if P.place then
            l, t = P.place[1] / s, P.place[2] / s
        else
            l, t = f:GetLeft(), f:GetTop()
            if not l then return end
        end
        -- en unités de l'écran (celles d'UIParent)
        local g, d = (l - D.gauche) * s, (l + f:GetWidth() + D.droite) * s
        local hh, b = (t + D.haut) * s, (t - f:GetHeight() - D.bas) * s
        local dx, dy = 0, 0
        if d > W then dx = W - d end
        if g + dx < 0 then dx = -g end
        if hh > H then dy = H - hh end
        if b + dy < 0 then dy = -b end
        if P.place or dx ~= 0 or dy ~= 0 then
            f:ClearAllPoints()
            f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", l + dx / s, t + dy / s)
            if P.place then P.place = { (l + dx / s) * s, (t + dy / s) * s } end
        end
    end

    -- SelectPage : la page clé se montre (construite à sa première ouverture),
    -- les autres se cachent, son onglet est coché
    function P.Choisir(cle)
        local d = P.pages[cle]
        if not d then return end
        if not d.construite then
            d.construite = true
            d.construire(d.page)
        end
        for _, c in ipairs(P.ordre) do
            if c ~= cle then P.pages[c].page:Hide() end
        end
        P.courante = cle
        if dimensionner(d) and P.fenetre:IsShown() then UpdateUIPanelPositions(P.fenetre) end
        d.page:Show()
        majOnglets()
        P.Recadrer()
    end

    -- tri des onglets : ordre, puis clé
    local function avant(a, b)
        local x, y = P.pages[a], P.pages[b]
        if x.ordre ~= y.ordre then return x.ordre < y.ordre end
        return a < b
    end

    function P.Ajouter(d)
        if type(d) ~= "table" or type(d.cle) ~= "string" or type(d.construire) ~= "function" then return nil end
        local f = P.Construire(d.portrait)
        P.nom = P.nom or d.nomFenetre
        local ancienne = P.pages[d.cle]
        local montree = ancienne and ancienne.page:IsShown() and f:IsShown()
        if ancienne then
            ancienne.page:Hide()
        else
            table.insert(P.ordre, d.cle)
        end
        local page = CreateFrame("Frame", nil, f)
        page:SetAllPoints(f)
        page:SetFrameLevel(f:GetFrameLevel() + N.niveaux.page)
        page:Hide()
        P.pages[d.cle] = {
            cle = d.cle, ordre = tonumber(d.ordre) or 100, titre = d.titre or d.cle, icone = d.icone,
            construire = d.construire, page = page,
            taille = type(d.taille) == "table" and d.taille or nil,
        }
        table.sort(P.ordre, avant)
        if montree then P.Choisir(d.cle) end
        if ForeverUI and ForeverUI.TabMacros then
            ForeverUI.TabMacros.Register(corpsMacro(d.cle), infoMacro(d.cle))
        end
        majOnglets()
        majMicro()
        return page
    end

    -- ToggleLegacySystemUI : la page clé (sinon la dernière montrée, sinon la
    -- première)
    function P.Ouvrir(cle)
        if #P.ordre == 0 then return end
        local f = P.Construire()
        if not (cle and P.pages[cle]) then
            cle = (P.courante and P.pages[P.courante]) and P.courante or P.ordre[1]
        end
        if not f:IsShown() then ShowUIPanel(f) end
        if f:IsShown() and not (P.courante == cle and P.pages[cle].page:IsShown()) then
            P.Choisir(cle)
        end
        -- ShowUIPanel la place par la méthode du client, sans passer par le
        -- UpdateUIPanelPositions global que suit P.Construire
        P.Recadrer()
    end

    function P.Fermer()
        if P.fenetre and P.fenetre:IsShown() then HideUIPanel(P.fenetre) end
    end

    -- la fenêtre ouverte sur cette page (ou sur toute page, sans clé) se ferme ;
    -- sinon elle s'ouvre sur elle
    function P.Basculer(cle)
        local f = P.fenetre
        if f and f:IsShown() and (not cle or cle == P.courante) then
            P.Fermer()
        else
            P.Ouvrir(cle)
        end
    end

    function P.Montree(cle)
        local f = P.fenetre
        return (f and f:IsShown() and P.courante == cle) and true or false
    end
end
-- ---------------------------------------------------------------------------
-- FIN DE LA FENÊTRE PROGRESSION (copie commune)
-- ---------------------------------------------------------------------------
