/*
SoftFX (Software graphics manipulation library)
Copyright (C) 2003 Kevin Gadd

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

/*
These templates were written by Chad Austin.
His site is at http://www.aegisknight.org/.
He rules. Thanks, Chad!
*/

template<typename T>
class zeroinit {
public:
    zeroinit() : _value(0) { }
    zeroinit(const T& t) : _value(t) { }

    operator T&() { return _value; }
    operator const T&() const { return _value; }

private:
    T _value;
};

template<typename T, T initVal = 0>
class autoinit {
public:
    autoinit() : _value(initVal) { }
    autoinit(const T& t) : _value(t) { }

    operator T&() { return _value; }
    operator const T&() const { return _value; }

private:
    T _value;
};