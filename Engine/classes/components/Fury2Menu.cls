VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Fury2Menu"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Description = "Fury� Generic Menu Plugin"
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Collection" ,"Fury2MenuItem"
Attribute VB_Ext_KEY = "Member0" ,"Fury2MenuItem"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
'
'    Engine (Fury� Game Creation System Runtime Engine)
'    Copyright (C) 2003 Kevin Gadd
'
'    This library is free software; you can redistribute it and/or
'    modify it under the terms of the GNU Lesser General Public
'    License as published by the Free Software Foundation; either
'    version 2.1 of the License, or (at your option) any later version.
'
'    This library is distributed in the hope that it will be useful,
'    but WITHOUT ANY WARRANTY; without even the implied warranty of
'    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
'    Lesser General Public License for more details.
'
'    You should have received a copy of the GNU Lesser General Public
'    License along with this library; if not, write to the Free Software
'    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
'

Option Compare Text
Option Explicit

Implements Fury2Plugin
Implements Fury2Object
Implements IVirtualFileSaveable

Private mCol As Collection
Public Active As Boolean
Attribute Active.VB_VarDescription = "If True, the menu will respond to input."
Public DrawBehind As Boolean
Attribute DrawBehind.VB_VarDescription = "If True, the menu will be drawn behind picture slots."
Public Engine As Fury2Engine
Attribute Engine.VB_VarDescription = "I"
Public Rectangle As Fury2Rect
Attribute Rectangle.VB_VarDescription = "The rectangle this menu occupies."
Private m_lngSelectedItem As Long
Public ScrollOffset As Long
Attribute ScrollOffset.VB_VarDescription = "The scroll position of the menu (in items)."
Public Cursor As Object
Attribute Cursor.VB_VarDescription = "The cursor that will be drawn next to the selected menu item."
Public WindowSkin As Fury2WindowSkin
Attribute WindowSkin.VB_VarDescription = "The window skin used by the menu."
Public Font As Fury2Font
Attribute Font.VB_VarDescription = "The Font used by the menu to draw items."
Public MoveEvent As Fury2Event
Attribute MoveEvent.VB_VarDescription = "This event will be invoked when the cursor moves."
Public CloseEvent As Fury2Event
Attribute CloseEvent.VB_VarDescription = "This event will be invoked when the menu is closed for any reason."
Public SelectEvent As Fury2Event
Attribute SelectEvent.VB_VarDescription = "This event will be invoked when an item is selected."
Public Title As String
Attribute Title.VB_VarDescription = "The title string to display at the top of the menu."
Public TitleFont As Fury2Font
Attribute TitleFont.VB_VarDescription = "The font to use to draw the title string."
Public TabStops As Variant
#If EnableBehaviors = 1 Then
Public Behaviors As Fury2Behaviors
#End If
Public Alpha As Single
Private m_lngVisibleLines As Long
Private m_varLineHeights As Variant

Public Property Get SelectedItem() As Long
Attribute SelectedItem.VB_Description = "The index of the selected item."
On Error Resume Next
    SelectedItem = m_lngSelectedItem
End Property

Public Property Let SelectedItem(ByVal NewItem As Long)
On Error Resume Next
    If mCol.Item(NewItem).Enabled = False Then Exit Property
    m_lngSelectedItem = NewItem
    If m_lngSelectedItem < 1 Then m_lngSelectedItem = 1
    If m_lngSelectedItem > mCol.Count Then m_lngSelectedItem = mCol.Count
End Property

Public Sub Clear()
Attribute Clear.VB_Description = "Removes all the items from the menu."
On Error Resume Next
    Do While mCol.Count > 0
        mCol.Remove 1
    Loop
    Set mCol = New Collection
    ScrollOffset = 0
End Sub

Private Sub SelectionChanged()
On Error Resume Next
    If Not (MoveEvent Is Nothing) Then MoveEvent.Invoke
    Err.Clear
End Sub

Private Sub ItemSelect(Index)
On Error Resume Next
    If mCol.Item(Index).Enabled = False Then Exit Sub
    If mCol.Item(Index).SelectEvent Is Nothing Then
        Err.Clear
        mCol.Item(Index).SelectEvent.Invoke mCol.Item(Index).Index
        If Err <> 0 Then mCol.Item(Index).SelectEvent.Invoke
    End If
    If Not (SelectEvent Is Nothing) Then
        Err.Clear
        SelectEvent.Invoke mCol.Item(Index).Index
        If Err <> 0 Then SelectEvent.Invoke
    End If
    Err.Clear
End Sub

Private Sub CloseMenu()
On Error Resume Next
    If Not (CloseEvent Is Nothing) Then CloseEvent.Invoke
End Sub

Public Sub MouseUp(ByVal Button As Long, ByVal Shift As Long, ByRef X As Long, ByRef Y As Long)
On Error Resume Next
Dim m_lngOldItem As Long
Dim m_lngItems As Long, m_lngY As Long, m_lngLastY As Long
Dim m_lngSpace As Long
    If Me.Active = False Then Exit Sub
    If WindowSkin Is Nothing Then
        m_lngSpace = 2
    Else
        m_lngSpace = 2
    End If
    If X >= Rectangle.left And X < Rectangle.right And Y >= Rectangle.top And Y < Rectangle.bottom Then
        m_lngSelectedItem = ((Y - (Rectangle.top + m_lngSpace)) \ Font.Height) + 1 + ScrollOffset
        If m_lngSelectedItem < 1 Then m_lngSelectedItem = 1
        If m_lngSelectedItem > mCol.Count Then m_lngSelectedItem = mCol.Count
        If Button = 1 Then
            ItemSelect m_lngSelectedItem
        ElseIf Button = 2 Then
            CloseMenu
        End If
        X = -32767
        Y = -32767
    End If
End Sub

Public Sub MouseMove(ByVal Button As Long, ByVal Shift As Long, ByRef X As Long, ByRef Y As Long)
On Error Resume Next
Dim m_lngOldItem As Long
Dim m_lngItems As Long, m_lngY As Long, m_lngLastY As Long
Dim m_lngSpace As Long
    If Me.Active = False Then Exit Sub
    If WindowSkin Is Nothing Then
        m_lngSpace = 2
    Else
        m_lngSpace = 2
    End If
    If X >= Rectangle.left And X < Rectangle.right And Y >= Rectangle.top And Y < Rectangle.bottom Then
        m_lngOldItem = m_lngSelectedItem
        Err.Clear
        m_lngSelectedItem = ((Y - (Rectangle.top + m_lngSpace)) \ Font.Height) + 1 + ScrollOffset
        If mCol.Item(m_lngSelectedItem).Enabled Then
        Else
            m_lngSelectedItem = m_lngOldItem
        End If
        If mCol.Count > m_lngVisibleLines Then
            If (Y < Rectangle.top + m_lngSpace) Then
                ScrollOffset = ScrollOffset - 1
            ElseIf (Y > Rectangle.bottom - m_lngSpace) Then
                ScrollOffset = ScrollOffset + 1
            End If
            If ScrollOffset < 0 Then ScrollOffset = 0
            If ScrollOffset > (mCol.Count - m_lngVisibleLines) + 1 Then ScrollOffset = (mCol.Count - m_lngVisibleLines) + 1
        Else
            ScrollOffset = 0
        End If
        If m_lngSelectedItem < 1 Then m_lngSelectedItem = 1
        If m_lngSelectedItem > mCol.Count Then m_lngSelectedItem = mCol.Count
        If m_lngOldItem <> m_lngSelectedItem Then
            SelectionChanged
        End If
        X = -32767
        Y = -32767
    End If
End Sub

Public Sub Redraw()
Attribute Redraw.VB_Description = "Redraws the menu."
On Error Resume Next
Static Here As Boolean
Dim m_fntOldFont As StdFont
Dim m_lngDrawItems As Long
Dim m_lngItemHeight As Long
Dim m_lngCurrentY As Long
Dim m_fmiItem As Fury2MenuItem
Dim m_rctItem As Fury2Rect
Dim m_lngArrowCoord As Long
Dim m_lngSpace As Long, m_lngAlpha As Long
Dim m_strCaption As String
Dim l_rctTitle As Fury2Rect
Dim l_varStops As Variant
    If m_lngSelectedItem < 1 Then m_lngSelectedItem = 1
    If m_lngSelectedItem > mCol.Count Then m_lngSelectedItem = mCol.Count
    If (TabStops <> vbEmpty) Then
        l_varStops = Font.TabStops
        Font.TabStops = TabStops
    End If
    m_lngAlpha = Alpha * 255
    m_lngVisibleLines = (Rectangle.Height - (m_lngSpace * 2)) \ Font.Height
    If mCol.Count > m_lngVisibleLines Then
        If (m_lngSelectedItem - ScrollOffset) < 1 Then
            ScrollOffset = ScrollOffset - 1
        ElseIf (m_lngSelectedItem - ScrollOffset) >= m_lngVisibleLines Then
            ScrollOffset = ScrollOffset + 1
        End If
        If ScrollOffset < 0 Then ScrollOffset = 0
        If ScrollOffset > (mCol.Count - m_lngVisibleLines) + 1 Then ScrollOffset = (mCol.Count - m_lngVisibleLines) + 1
    Else
        ScrollOffset = 0
    End If
    With Engine.Backbuffer
        m_lngSpace = 2
        If WindowSkin.EdgeOverlap Then
            WindowSkin.Draw Engine.Backbuffer, Rectangle, Alpha, SF_Middle
        Else
            WindowSkin.Draw Engine.Backbuffer, Rectangle, Alpha
        End If
        Set l_rctTitle = TitleFont.GetTextRectangle(Title)
        TitleFont.Draw Engine.Backbuffer, Title, F2Rect(Rectangle.left, Rectangle.top - l_rctTitle.Height, Rectangle.right, l_rctTitle.Height, False), , Alpha
        Set .ClipRectangle = Me.Rectangle
        m_lngCurrentY = Rectangle.top + m_lngSpace
        If mCol.Count >= 1 + Me.ScrollOffset Then
            Set m_rctItem = New Fury2Rect
            m_rctItem.SetValues Rectangle.left + m_lngSpace, 0, Rectangle.right - m_lngSpace, 0
            For m_lngDrawItems = 1 + Me.ScrollOffset To mCol.Count
                Set m_fmiItem = mCol.Item(m_lngDrawItems)
                With m_fmiItem
                    m_strCaption = .Caption
                    If InStr(m_strCaption, "<%=") Then
                        m_strCaption = Engine.ParseString(m_strCaption)
                    End If
                    If m_lngCurrentY >= Rectangle.bottom - m_lngSpace Then Exit For
'                    m_lngItemHeight = Font.Height
                    If .Icon Is Nothing Then
                        m_rctItem.SetValues Rectangle.left + m_lngSpace, m_lngCurrentY, m_rctItem.right, Rectangle.bottom
                        m_lngItemHeight = Font.Draw(Engine.Backbuffer, m_strCaption, m_rctItem, m_fmiItem.Color, Alpha * .Alpha) * Font.Height
                        If m_lngDrawItems = m_lngSelectedItem Then
                            m_lngArrowCoord = m_lngCurrentY + (m_lngItemHeight \ 2)
                        End If
                        m_lngCurrentY = m_lngCurrentY + m_lngItemHeight
                    Else
                        m_rctItem.SetValues Rectangle.left + m_lngSpace + .Icon.Width, m_lngCurrentY, m_rctItem.right, Rectangle.bottom
                        m_lngItemHeight = Font.Draw(Engine.Backbuffer, m_strCaption, m_rctItem, m_fmiItem.Color, Alpha * .Alpha) * Font.Height
                        If (.Icon.Height > m_lngItemHeight) Then m_lngItemHeight = .Icon.Height
                        .Icon.Draw Engine.Backbuffer, Rectangle.left + m_lngSpace, m_lngCurrentY + m_lngItemHeight \ 2, Alpha * .Alpha
                        If m_lngDrawItems = m_lngSelectedItem Then
                            m_lngArrowCoord = m_lngCurrentY + (m_lngItemHeight \ 2)
                        End If
                        m_lngCurrentY = m_lngCurrentY + m_lngItemHeight
                    End If
                End With
            Next m_lngDrawItems
'            m_lngArrowCoord = ((m_lngSelectedItem - Me.ScrollOffset) - 1) * Font.Height
            Set .ClipRectangle = F2Rect(0, Rectangle.top, .Width, Rectangle.bottom, False)
        End If
        .UpdateClipRect
        If WindowSkin.EdgeOverlap Then
            WindowSkin.Draw Engine.Backbuffer, Rectangle, Alpha, SF_All Xor SF_Middle
        End If
        If m_lngArrowCoord = c_lngNullValue Then
        Else
            Cursor.Draw Engine.Backbuffer, Rectangle.left, m_lngArrowCoord, Alpha
        End If
    End With
    If mCol.Count > m_lngVisibleLines Then
        If ScrollOffset < 0 Then ScrollOffset = 0
        If ScrollOffset > (mCol.Count - m_lngVisibleLines) + 1 Then ScrollOffset = (mCol.Count - m_lngVisibleLines) + 1
    Else
        ScrollOffset = 0
    End If
    If (TabStops <> vbEmpty) Then
        Font.TabStops = l_varStops
    End If
    Err.Clear
End Sub

Sub Startup()
On Error Resume Next
    If Engine.EnableObjectEvents Then Engine.ScriptEngine.Exec "Menu_Create", Me
    Err.Clear
    Me.Active = True
End Sub

Public Sub Update()
Attribute Update.VB_Description = "U"
On Error Resume Next
#If EnableBehaviors = 1 Then
    If Engine.EnableObjectEvents Then
    Else
        Behaviors.Reset
    End If
    Behaviors.SetParent Me
    Behaviors.Update
#End If
    mCol(m_lngSelectedItem).Update
    Err.Clear
End Sub

Public Function Add(Caption As String, Optional Icon = Nothing, Optional SelectEvent = Nothing, Optional Index As Long = -1, Optional Color = &HFFFFFFFF) As Fury2MenuItem
Attribute Add.VB_Description = "Adds a new item to the menu."
On Error Resume Next
    Dim objNewMember As Fury2MenuItem
    Set objNewMember = New Fury2MenuItem
    
    objNewMember.Caption = Caption
    Err.Clear
    Set objNewMember.Icon = Icon
    If Err <> 0 Then
        Err.Clear
        Set objNewMember.Icon = Engine.F2Graphic(Icon, Icon.Width / 4, Icon.Height / 4)
    End If
    objNewMember.Color = CLng(Color)
    Set objNewMember.SelectEvent = Engine.BindEvent(SelectEvent)
    objNewMember.Alpha = 1
    objNewMember.Enabled = True
    If Index = -1 Then Index = mCol.Count + 1
    objNewMember.Index = Index
    mCol.Add objNewMember

    Set Add = objNewMember
    Set objNewMember = Nothing
End Function

Public Property Get Item(ByVal vntIndexKey As Variant) As Fury2MenuItem
Attribute Item.VB_Description = "Retrieves an item from the menu."
Attribute Item.VB_UserMemId = 0
On Error Resume Next
  Set Item = mCol(vntIndexKey)
End Property

Public Property Get Count() As Long
Attribute Count.VB_Description = "The number of items in the menu."
On Error Resume Next
    Count = mCol.Count
End Property

Public Sub Remove(vntIndexKey As Variant)
Attribute Remove.VB_Description = "Removes an item from the menu."
On Error Resume Next
    mCol.Remove vntIndexKey
End Sub

Public Property Get NewEnum() As IUnknown
Attribute NewEnum.VB_UserMemId = -4
Attribute NewEnum.VB_MemberFlags = "40"
On Error Resume Next
    Set NewEnum = mCol.[_NewEnum]
End Property

Private Sub Class_Initialize()
On Error Resume Next
    Set mCol = New Collection
    Set Rectangle = New Fury2Rect
#If EnableBehaviors = 1 Then
    Set Behaviors = New Fury2Behaviors
    Behaviors.SetParent Me
#End If
    m_lngSelectedItem = 1
End Sub

Private Sub Class_Terminate()
On Error Resume Next
    Set mCol = Nothing
End Sub

Private Sub Fury2Plugin_ControlActivate(Control As Fury2InputControl)
Dim l_lngOldItem As Long
    If Me.Active = False Then Exit Sub
    l_lngOldItem = m_lngSelectedItem
    If (Control.Name = "Up") Then
        Control.Consume
        m_lngSelectedItem = m_lngSelectedItem - 1
        If m_lngSelectedItem < 1 Then m_lngSelectedItem = 1
        If m_lngSelectedItem > mCol.Count Then m_lngSelectedItem = mCol.Count
        Do While (mCol.Item(m_lngSelectedItem).Enabled = False)
            m_lngSelectedItem = m_lngSelectedItem - 1
            If m_lngSelectedItem < 1 Then m_lngSelectedItem = 1: Exit Do
            If m_lngSelectedItem > mCol.Count Then m_lngSelectedItem = mCol.Count: Exit Do
            If m_lngSelectedItem = l_lngOldItem Then Exit Do
        Loop
        If mCol.Item(m_lngSelectedItem).Enabled Then
        Else
            m_lngSelectedItem = l_lngOldItem
        End If
        SelectionChanged
    ElseIf (Control.Name = "Down") Then
        Control.Consume
        m_lngSelectedItem = m_lngSelectedItem + 1
        If m_lngSelectedItem < 1 Then m_lngSelectedItem = 1
        If m_lngSelectedItem > mCol.Count Then m_lngSelectedItem = mCol.Count
        Do While (mCol.Item(m_lngSelectedItem).Enabled = False)
            m_lngSelectedItem = m_lngSelectedItem + 1
            If m_lngSelectedItem < 1 Then m_lngSelectedItem = 1: Exit Do
            If m_lngSelectedItem > mCol.Count Then m_lngSelectedItem = mCol.Count: Exit Do
            If m_lngSelectedItem = l_lngOldItem Then Exit Do
        Loop
        If mCol.Item(m_lngSelectedItem).Enabled Then
        Else
            m_lngSelectedItem = l_lngOldItem
        End If
        SelectionChanged
    ElseIf (Control.Name = "OK") Or (Control.Name = "Select") Or (Control.Name = "Primary") Then
        Control.Consume
        If m_lngSelectedItem < 1 Then m_lngSelectedItem = 1
        If m_lngSelectedItem > mCol.Count Then m_lngSelectedItem = mCol.Count
        ItemSelect m_lngSelectedItem
    ElseIf (Control.Name = "Cancel") Or (Control.Name = "Close") Or (Control.Name = "Secondary") Then
        Control.Consume
        CloseMenu
    End If
End Sub

Private Sub Fury2Plugin_ControlDeactivate(Control As Fury2InputControl)
End Sub

Private Property Get Fury2Plugin_DrawBehind() As Boolean
    Fury2Plugin_DrawBehind = DrawBehind
End Property

Private Property Set Fury2Plugin_Engine(ByVal RHS As Fury2Engine)
    Set Engine = RHS
End Property

Private Property Get Fury2Plugin_Engine() As Fury2Engine
    Set Fury2Plugin_Engine = Engine
End Property

Private Sub Fury2Plugin_Init()
End Sub

Private Sub Fury2Plugin_KeyDown(KeyCode As Long, ByVal Shift As Long)
End Sub

Private Sub Fury2Plugin_KeyPress(KeyAscii As Long)
End Sub

Private Sub Fury2Plugin_KeyUp(KeyCode As Long, ByVal Shift As Long)
End Sub

Private Sub Fury2Plugin_MapLoad(Filename As String)
End Sub

Private Sub Fury2Plugin_MouseDown(ByVal Button As Long, ByVal Shift As Long, ByRef X As Long, ByRef Y As Long)
End Sub

Private Sub Fury2Plugin_MouseMove(ByVal Button As Long, ByVal Shift As Long, ByRef X As Long, ByRef Y As Long)
    MouseMove Button, Shift, X, Y
End Sub

Private Sub Fury2Plugin_MouseUp(ByVal Button As Long, ByVal Shift As Long, ByRef X As Long, ByRef Y As Long)
    MouseUp Button, Shift, X, Y
End Sub

Private Sub Fury2Plugin_Redraw()
    Redraw
End Sub

Private Sub Fury2Plugin_Shutdown()
End Sub

Private Sub Fury2Plugin_Startup()
    Startup
End Sub

Private Sub Fury2Plugin_SyncUpdate()
End Sub

Private Sub Fury2Plugin_Unload()
End Sub

Private Sub Fury2Plugin_Update()
    Update
End Sub

Private Sub IVirtualFileSaveable_Deserialize(File As libGraphics.VirtualFile)
On Error Resume Next
    With File
        .ReadSegment_Begin
        .ReadSegment_End
    End With
End Sub

Private Sub IVirtualFileSaveable_Serialize(File As libGraphics.VirtualFile)
On Error Resume Next
    With File
        .WriteSegment_Begin
        .WriteSegment_End
    End With
End Sub

Private Sub Fury2Plugin_OutputPluginChanged()
End Sub


