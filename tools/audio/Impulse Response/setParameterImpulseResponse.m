function parameter = setParameterImpulseResponse(impulseResponse)
if impulseResponse == 1
    parameter.impulseResponse = 'GreatHall1';
elseif impulseResponse == 2
    parameter.impulseResponse = 'Classroom1';
elseif impulseResponse == 3
    parameter.impulseResponse = 'Octagon1';
elseif impulseResponse == 4
    parameter.impulseResponse = 'GoogleNexusOneFrontSpeaker';
elseif impulseResponse == 5
    parameter.impulseResponse = 'GoogleNexusOneFrontMic';
elseif impulseResponse == 6
    parameter.impulseResponse = 'VinylPlayer1960';
    %the default choice is Great Hall 1
else
    parameter.impulseResponse = 'GreatHall1';
end
end