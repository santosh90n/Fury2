VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ImportTTFOptions"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'
'    ngPlugins (Fury� Game Creation System Next-Generation Editor Standard Plugin Set)
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

Implements IVirtualFileSaveable
Implements IInspectable

Private mvarCharacterSet As String
Private mvarEnableUnicode As Boolean
Private mvarName As String
Private mvarSize As Single
Private mvarBold As Boolean
Private mvarItalic As Boolean

Public Property Get CharacterSet() As String
    CharacterSet = mvarCharacterSet
End Property

Public Property Let CharacterSet(ByRef vData As String)
    mvarCharacterSet = vData
End Property

Public Property Get Name() As String
    Name = mvarName
End Property

Public Property Let Name(ByRef vData As String)
    mvarName = vData
End Property

Public Property Get Size() As Single
    Size = mvarSize
End Property

Public Property Let Size(ByVal vData As Single)
    mvarSize = vData
End Property

Public Property Get Bold() As Boolean
    Bold = mvarBold
End Property

Public Property Let Bold(ByVal vData As Boolean)
    mvarBold = vData
End Property

Public Property Get EnableUnicode() As Boolean
    EnableUnicode = mvarEnableUnicode
End Property

Public Property Let EnableUnicode(ByVal vData As Boolean)
    mvarEnableUnicode = vData
End Property

Public Property Get Italic() As Boolean
    Italic = mvarItalic
End Property

Public Property Let Italic(ByVal vData As Boolean)
    mvarItalic = vData
End Property

Private Sub Class_Initialize()
    mvarName = "Tahoma"
    mvarCharacterSet = "Standard"
    mvarSize = 8
    mvarEnableUnicode = False
End Sub

Private Sub IVirtualFileSaveable_Deserialize(File As libGraphics.VirtualFile)
    With File
        .Load mvarName
        .Load mvarSize
        .Load mvarBold
        .Load mvarItalic
        .Load mvarEnableUnicode
        .Load mvarCharacterSet
    End With
End Sub

Private Sub IVirtualFileSaveable_Serialize(File As libGraphics.VirtualFile)
    With File
        .Save mvarName
        .Save mvarSize
        .Save mvarBold
        .Save mvarItalic
        .Save mvarEnableUnicode
        .Save mvarCharacterSet
    End With
End Sub

