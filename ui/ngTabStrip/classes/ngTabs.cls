VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ngTabs"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Description = "Fury� Generic Collection Object"
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Collection" ,"Obj"
Attribute VB_Ext_KEY = "Member0" ,"Obj"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
Option Explicit
Implements IVirtualFileSaveable

Private m_tbsParent As ngTabStrip
Private m_colCollection As Collection

Friend Sub Free()
On Error Resume Next
Dim l_tabTab As ngTab
    Set m_tbsParent = Nothing
    For Each l_tabTab In m_colCollection
        l_tabTab.Free
    Next l_tabTab
End Sub

Friend Sub Reindex()
On Error Resume Next
Dim l_tabTab As ngTab
Dim l_lngIndex As Long
    l_lngIndex = 1
    For Each l_tabTab In m_colCollection
        l_tabTab.Index = l_lngIndex
        l_lngIndex = l_lngIndex + 1
    Next l_tabTab
End Sub

Friend Sub SetParent(Parent As ngTabStrip)
On Error Resume Next
    Set m_tbsParent = Parent
End Sub

Public Function AddNew(Optional ByRef Text As String = "", Optional ByRef Key As String = "", Optional ByRef Image As Variant = Nothing, Optional ByRef Tooltip As String = "", Optional ByVal TextAlignment As ngTabTextAlignment = tsaRight, Optional ByVal Enabled As Boolean = True, Optional ByVal AtIndex As Long = -1) As ngTab
On Error Resume Next
Dim l_tabNew As ngTab
Dim l_imgImage As Fury2Image
Dim l_picImage As StdPicture
Dim l_resFile As ngResource
    Set l_tabNew = New ngTab
    With l_tabNew
        .Key = Key
        .Text = Text
        .Tooltip = Tooltip
        If VarType(Image) = vbString Then
            Set l_resFile = m_tbsParent.ResourceFile(Replace(m_tbsParent.ResourcePattern, "*", Image))
            If Not (l_resFile Is Nothing) Then
                Set .Image = l_resFile.LoadImage()
            End If
        ElseIf VarType(Image) = vbObject Then
            If TypeOf Image Is Fury2Image Then
                Set l_imgImage = Image
                Set .Image = l_imgImage
            End If
        End If
        .TextAlignment = TextAlignment
        .Enabled = Enabled
    End With
    Add l_tabNew, AtIndex
    Set AddNew = l_tabNew
End Function

Public Sub Add(ByVal Obj As ngTab, Optional ByVal AtIndex As Long = -1)
On Error Resume Next
Dim l_strKey As String
    l_strKey = Obj.Key
    If Len(l_strKey) = 0 Then
        If AtIndex = -1 Then
            m_colCollection.Add Obj
        Else
            If (m_colCollection.Count = 0) Or (AtIndex > m_colCollection.Count) Then
                m_colCollection.Add Obj
            ElseIf AtIndex <= 1 Then
                m_colCollection.Add Obj, , 1
            ElseIf m_colCollection.Count > AtIndex Then
                m_colCollection.Add Obj, , AtIndex
            Else
                m_colCollection.Add Obj, , , AtIndex - 1
            End If
        End If
    Else
        If AtIndex = -1 Then
            m_colCollection.Add Obj, l_strKey
        Else
            If (m_colCollection.Count = 0) Or (AtIndex > m_colCollection.Count) Then
                m_colCollection.Add Obj, l_strKey
            ElseIf AtIndex <= 1 Then
                m_colCollection.Add Obj, l_strKey, 1
            ElseIf m_colCollection.Count > AtIndex Then
                m_colCollection.Add Obj, l_strKey, AtIndex
            Else
                m_colCollection.Add Obj, l_strKey, , AtIndex - 1
            End If
        End If
    End If
    Obj.SetParent m_tbsParent
    Reindex
    m_tbsParent.Reflow
    If m_colCollection.Count = 1 Then
        m_tbsParent.SelectTab 1
    End If
    Err.Clear
End Sub

Public Property Get Item(ByVal IndexOrKey) As ngTab
Attribute Item.VB_UserMemId = 0
On Error Resume Next
    If VarType(IndexOrKey) = vbString Then
        IndexOrKey = CStr(IndexOrKey)
    End If
    Err.Clear
    Set Item = m_colCollection(IndexOrKey)
    Err.Clear
End Property

Public Function Find(ByVal Obj As ngTab) As Long
On Error Resume Next
Dim l_lngItems As Long, l_tabItem As ngTab
    If m_colCollection.Count <= 0 Then Exit Function
    l_lngItems = 1
    For Each l_tabItem In m_colCollection
        If l_tabItem Is Obj Then
            Find = l_lngItems
            Exit Function
        End If
        l_lngItems = l_lngItems + 1
    Next l_tabItem
End Function

Public Property Get Count() As Long
On Error Resume Next
    Count = m_colCollection.Count
End Property

Public Sub Remove(ByVal IndexOrKey)
On Error Resume Next
    If VarType(IndexOrKey) = vbString Then
        IndexOrKey = CStr(IndexOrKey)
    ElseIf VarType(IndexOrKey) = vbObject Then
        IndexOrKey = Find(IndexOrKey)
    Else
        IndexOrKey = CLng(IndexOrKey)
    End If
    m_colCollection.Remove IndexOrKey
    Reindex
    m_tbsParent.Reflow
End Sub

Public Sub RemoveByKeys(ByVal KeyPattern As String)
On Error Resume Next
Dim l_lngIndex As Long
Dim l_tabTab As ngTab
    Do Until l_lngIndex > m_colCollection.Count
        l_lngIndex = 1
        Set l_tabTab = m_colCollection(l_lngIndex)
        If l_tabTab.Key Like KeyPattern Then
            m_colCollection.Remove l_lngIndex
        Else
            l_lngIndex = l_lngIndex + 1
        End If
    Loop
    Reindex
End Sub

Public Sub Move(ByVal FromIndex As Long, ByVal ToIndex As Long)
On Error Resume Next
Dim l_tabTab As Object
    If FromIndex < 1 Or FromIndex > m_colCollection.Count Then Exit Sub
    If ToIndex < 1 Or ToIndex > (m_colCollection.Count + 1) Then Exit Sub
    If FromIndex = ToIndex Then Exit Sub
    Set l_tabTab = m_colCollection.Item(FromIndex)
    Remove FromIndex
    If (FromIndex < ToIndex) Then
'        Trust me, this works - even though it doesn't make sense unless you think about it
'        ToIndex = ToIndex - 1
    End If
    Add l_tabTab, ToIndex
End Sub

Public Sub Clear()
On Error Resume Next
Dim l_tabTab As ngTab
    For Each l_tabTab In m_colCollection
        l_tabTab.Free
    Next l_tabTab
    Set m_colCollection = New Collection
    m_tbsParent.Reflow
    m_tbsParent.SelectTab Nothing
End Sub

Public Property Get NewEnum() As IUnknown
Attribute NewEnum.VB_UserMemId = -4
Attribute NewEnum.VB_MemberFlags = "40"
On Error Resume Next
    Set NewEnum = m_colCollection.[_NewEnum]
End Property

Private Sub Class_Initialize()
On Error Resume Next
    Set m_colCollection = New Collection
End Sub

Private Sub Class_Terminate()
On Error Resume Next
    Set m_colCollection = Nothing
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

