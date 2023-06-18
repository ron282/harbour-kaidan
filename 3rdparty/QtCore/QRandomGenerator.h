#pragma once

#include <random>
class QRandomGenerator {
public:
	QRandomGenerator()
	{

	}
	static QRandomGenerator *system() {
		static QRandomGenerator rg;
		return &rg; 
	}
	static QRandomGenerator *global() {
		static QRandomGenerator rg;
		return &rg; 
	}
	quint32 generate()
	{
		std::mt19937 gen32(time(0));
		return gen32();
	}
	quint64 generate64()
	{
		std::mt19937_64 gen64(time(0));
		return gen64();
	}
};
